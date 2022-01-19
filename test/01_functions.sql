-- Postgres STRING_AGG
-- See https://www.postgresql.org/docs/9.5/functions-aggregate.html
SELECT STRING_AGG(x,'|') FROM (VALUES('a'),('b'),('c')) t(x); -- 'a|b|c'

-- Note: Redshift LISTAGG requires a table field
-- See https://docs.aws.amazon.com/redshift/latest/dg/r_LISTAGG.html
SELECT LISTAGG_SFUNC((ARRAY['a','b'], ''), 'c', ','); -- ({a,b,c}, ',') (a LISTAGG_TYPE)
SELECT LISTAGG_FINAL((ARRAY['a','b','c'], ','), NULL, NULL); -- 'a,b,c'
SELECT LISTAGG(x, '$') FROM (VALUES('a'),('b'),('c')) t(x); -- 'a$b$c'

