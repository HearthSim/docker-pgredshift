-- stl_scan table
CREATE TABLE stl_scan AS SELECT a.n FROM generate_series(1, 30) as a(n);
