/**
 * Dummy implementation of set query_group ...;
 * https://docs.aws.amazon.com/redshift/latest/dg/r_query_group.html
 * Courtesy of Andrew Gierth
 */

#include "postgres.h"
#include "fmgr.h"
#include "utils/guc.h"


PG_MODULE_MAGIC;

void _PG_init(void);

static char *query_group = NULL;

/*
 * Module load callback
 */
void _PG_init(void) {
	/* Define custom GUC variables. */
	DefineCustomStringVariable(
		"query_group",
		"Redshift compatibility, ignored.",
		NULL,
		&query_group,
		"",
		PGC_USERSET,
		0,
		NULL,
		NULL,
		NULL
	);
}
