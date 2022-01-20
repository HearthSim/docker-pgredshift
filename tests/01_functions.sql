-- https://docs.aws.amazon.com/redshift/latest/dg/REGEXP_SUBSTR.html
-- Works on strings
select REGEXP_SUBSTR('foobarbequebazilbarfbonk', 'b[^b]+'); -- 'bar'
select REGEXP_SUBSTR('foobarbequebazilbarfbonk', 'b\\w'); -- 'ba'
select REGEXP_SUBSTR('foobarbequebazilbarfbonk', 'b\\w+'); -- 'barbequebazilbarfbonk'
select REGEXP_SUBSTR('foobarbequebazilbarfbonk', '[^b]{4}'); -- 'eque'
select REGEXP_SUBSTR('foobarbequebazilbarfbonk', 'o{2}'); -- 'oo'
select REGEXP_SUBSTR('foobarbequebazilbarfbonk', 'o{3}'); -- ''

-- Works on column names. Both queries should return the same values.
SELECT table_name FROM SVV_TABLES WHERE REGEXP_SUBSTR(table_name, 'pg_c\\w+') <> '' ORDER BY table_name;
SELECT table_name FROM SVV_TABLES WHERE table_name LIKE 'pg_c%' ORDER BY table_name;

