
-- stv_blocklist
CREATE TABLE stv_blocklist (
	slice INTEGER,
	col INTEGER,
	tbl INTEGER,
	blocknum INTEGER,
	num_values INTEGER,
	extended_limits INTEGER,
	minvalue BIGINT,
	maxvalue BIGINT,
	sb_pos INTEGER,
	pinned INTEGER,
	on_disk INTEGER,
	modified INTEGER,
	hdr_modified INTEGER,
	unsorted INTEGER,
	tombstone INTEGER,
	preferred_diskno INTEGER,
	"temporary" INTEGER,
	newblock INTEGER,
	num_readers INTEGER,
	flags INTEGER
);

-- stv_tbl_perm table
CREATE TABLE stv_tbl_perm (
	slice INTEGER,
	id INTEGER,
	name VARCHAR(72),
	rows BIGINT,
	sorted_rows BIGINT,
	"temp" INTEGER,
	db_id INTEGER,
	insert_pristine INTEGER,
	delete_pristine INTEGER,
	backup INTEGER
);
