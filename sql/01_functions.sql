-- json_extract_array_element_text()
CREATE FUNCTION json_extract_array_element_text(json_array text, array_index int) RETURNS text immutable as $$
import json
result = json.loads(json_array)[array_index]
return json.dumps(result)
$$ LANGUAGE plpythonu;

-- json_extract_path_text()
CREATE FUNCTION json_extract_path_text(json_string text, VARIADIC path_elems character[]) RETURNS text immutable as $$
import json
result = json.loads(json_string)
if path_elem not in result: return ""
result = result[path_elem]
return json.dumps(result)
$$ LANGUAGE plpythonu;

-- json_array_length()
CREATE FUNCTION json_array_length(json_array text) RETURNS int immutable as $$
import json
return len(json.loads(json_array))
$$ LANGUAGE plpythonu;

-- decode()
CREATE FUNCTION decode(expression int, search int, result int, "default" int) RETURNS int immutable as $$
return result if expression == search else default
$$ LANGUAGE plpythonu;

-- median()
CREATE FUNCTION _final_median(numeric[]) RETURNS numeric immutable as $$
	SELECT AVG(val) FROM (
		SELECT val FROM unnest($1) val
		ORDER BY 1
		LIMIT 2 - MOD(array_upper($1, 1), 2)
		OFFSET CEIL(array_upper($1, 1) / 2.0) - 1
	) sub;
$$ LANGUAGE sql;

CREATE AGGREGATE median(numeric) (
	SFUNC=array_append,
	STYPE=numeric[],
	FINALFUNC=_final_median,
	INITCOND='{}'
);

-- Drops dependencies first
DROP AGGREGATE IF EXISTS LISTAGG(text, text);
DROP FUNCTION IF EXISTS LISTAGG_FINAL(LISTAGG_TYPE, text, text);
DROP FUNCTION IF EXISTS LISTAGG_SFUNC(LISTAGG_TYPE, text, text);
DROP TYPE IF EXISTS LISTAGG_TYPE;

-- https://www.postgresql.org/docs/11/sql-createtype.html
CREATE TYPE LISTAGG_TYPE AS (
    a TEXT[],
    delim TEXT
);

CREATE OR REPLACE FUNCTION LISTAGG_SFUNC(LISTAGG_TYPE, text, text)
RETURNS LISTAGG_TYPE
LANGUAGE 'plpgsql'
AS $$
	DECLARE
		appended LISTAGG_TYPE;
	BEGIN
		appended.a := array_append($1.a, $2::text);
		appended.delim := $3;
		RETURN appended;
	END;
$$;

CREATE OR REPLACE FUNCTION LISTAGG_FINAL(LISTAGG_TYPE, text, text)
RETURNS TEXT
LANGUAGE 'plpgsql'
AS $$
	BEGIN
--		RAISE EXCEPTION 'BAD: %|%|%',$1,$2,$3;
		RETURN ARRAY_TO_STRING($1.a,$1.delim);
	END;
$$;

-- https://www.postgresql.org/docs/11/sql-createaggregate.html
-- https://www.postgresql.org/docs/11/xaggr.html
-- https://stackoverflow.com/q/67159133/326979
-- https://stackoverflow.com/q/46411209/326979
-- https://stackoverflow.com/a/48190288/326979
CREATE AGGREGATE LISTAGG(text, text) (
	sfunc = LISTAGG_SFUNC,
  stype = LISTAGG_TYPE,
  initcond = '({},",")',
  finalfunc = LISTAGG_FINAL,
	FINALFUNC_EXTRA
);
