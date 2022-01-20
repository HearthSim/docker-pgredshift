-- https://docs.aws.amazon.com/redshift/latest/dg/JSON_EXTRACT_ARRAY_ELEMENT_TEXT.html
DROP FUNCTION IF EXISTS json_extract_array_element_text;
CREATE OR REPLACE FUNCTION json_extract_array_element_text(json_array text, array_index int)
RETURNS text immutable
STRICT
LANGUAGE plpythonu
AS $$
	import json
	items = json.loads(json_array)
	if 0 <= array_index and array_index < len(items):
		return json.dumps(items[array_index]).strip('"')
	else:
		return None
$$;


-- https://docs.aws.amazon.com/redshift/latest/dg/JSON_EXTRACT_PATH_TEXT.html
-- This isn't needed as postgres include json_extract_path_text a function that does something similar.
-- See https://www.postgresql.org/docs/10/functions-json.html
DROP FUNCTION IF EXISTS json_extract_path_text;
CREATE OR REPLACE FUNCTION json_extract_path_text(json_string text, VARIADIC path_elems character[])
RETURNS text immutable
STRICT
LANGUAGE plpythonu
AS $$
  import json
  result = json.loads(json_string)
  for path_elem in path_elems:
      if path_elem not in result: return ""
      result = result[path_elem]
  return json.dumps(result).strip('"')
$$;


-- https://docs.aws.amazon.com/redshift/latest/dg/JSON_ARRAY_LENGTH.html
DROP FUNCTION IF EXISTS json_array_length;
CREATE OR REPLACE FUNCTION json_array_length(json_array text) RETURNS int immutable as $$
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
