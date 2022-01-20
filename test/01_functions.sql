-- These should work in Redshift and the docker container as of
-- select version(); -- PostgreSQL 8.0.2 on i686-pc-linux-gnu, compiled by GCC gcc (GCC) 3.4.2 20041017 (Red Hat 3.4.2-6.fc3), Redshift 1.0.34691

-- https://docs.aws.amazon.com/redshift/latest/dg/JSON_EXTRACT_ARRAY_ELEMENT_TEXT.html
SELECT json_extract_array_element_text('[1,2,3]', -1); -- NULL
SELECT json_extract_array_element_text('[1,2,3]', 0); -- 1
SELECT json_extract_array_element_text('[1,2,3]', 3); -- NULL
SELECT json_extract_array_element_text('["a","b","c"]', -1); -- NULL
SELECT json_extract_array_element_text('["a","b","c"]', 2); -- c
SELECT json_extract_array_element_text('["a","b","c"]', 3); -- NULL
SELECT json_extract_array_element_text(NULL, 0); -- NULL
SELECT json_extract_array_element_text('', 0); -- NULL

-- Built in pg_catalog.json_extract_path_text exists so we need to include the schema when calling.
-- See https://www.postgresql.org/docs/10/functions-json.html
SELECT json_extract_path_text('{"a":{"b":{"c":1}},"d":[2,3],"e":"f"}'::text, 'a'); -- {"b": {"c": 1}}
SELECT json_extract_path_text('{"a":{"b":{"c":1}},"d":[2,3],"e":"f"}'::text,'a.b'); -- NULL
SELECT json_extract_path_text('{"a":{"b":{"c":1}},"d":[2,3],"e":"f"}'::text,'d'); -- [2, 3]
SELECT json_extract_path_text('{"a":{"b":{"c":1}},"d":[2,3],"e":"f"}'::text,'e'); -- f
SELECT json_extract_path_text(NULL, 'a'); -- ERROR: function json_extract_path_text(unknown, integer) does not exist
SELECT json_extract_path_text(''::text, 'a'); -- ERROR: ValueError: No JSON object could be decoded


SELECT NOW(), getdate(); -- 2022-01-18 13:47:09.566 -0500,	2022-01-18 18:47:10.000
