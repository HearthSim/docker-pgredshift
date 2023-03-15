# docker-pgredshift

A docker image based on Debian with PostgreSQL which simulates an
[AWS Redshift](https://aws.amazon.com/redshift/) instance.


## Why?

Amazon Redshift is close enough to, and compatible enough with Postgres that you
can use a lot of Postgres tooling and queries with it transparently. But some of
its features, or slight differences with Postgres, may be harder to work around.

Amazon does not make a local instance of Redshift available, nor is the project
open source. This is especially annoying if you are writing tests against code
which has to run queries with Redshift-specific syntax in them. Postgres will
normally reject them unless you mock the features in some way.

That's what this project is. It's not meant to run in production, but it is meant
to help mock Redshift's features for testing purposes.

**PLEASE NOTE**: As of July 2018, very little is implemented. PRs welcome.


## Key differences

The ultimate goal of pgredshift is to be as close as possible to the real Redshift
in terms of feature parity. However, some key differences will remain:

- [Redshift is based on Postgres 8.0.2](https://docs.aws.amazon.com/redshift/latest/dg/c_redshift-and-postgres-sql.html),
  whereas pgredshift is based on Postgres 10 or newer.
- pgredshift will enforce various forms of data integrity (such as Foreign Key
  constraints) which Redshift [does not enforce](https://docs.aws.amazon.com/redshift/latest/dg/c_best-practices-defining-constraints.html).
- Some core changes Redshift made to Postgres may not be replicatable in Postgres.
- Do not expect performance and underlying data storage efficiency to ever be replicated.


## Features

The pgredshift image is build on top of Debian "Buster".

### plpythonu

The image is built with `plpythonu` (Python 2.7) language support.
More information:
<https://docs.aws.amazon.com/redshift/latest/dg/udf-python-language-support.html>

The following packages are installed:

- NumPy 1.8.2
- Pandas 0.18.1 (up from 0.14.1 on Redshift)
- python-dateutil 2.2
- PyTZ 2015.7
- SciPy 0.12.1
- six 1.3.0
- wsgiref 0.1.2
- enum34 1.1.6 (Not available on Redshift)
- psycopg2 2.7.5 (Not available on Redshift)

The image also includes pip, setuptools and wheel for Python 2.7.

### plpython3u

The image is built with `plpython3u` (Python 3.6) language support.
Although Redshift does not support Python 3, you may use this to help ensure
compatibility of UDFs across Python 2 and 3.

The image includes pip, setuptools and wheel for Python 3.6.


### Postgres extensions

#### `SET query_group`

The `query_group` extension adds support for the `SET query_group to ...` command.
Postgres does not allow setting unknown variables, so including that extension
prevents an error when issuing the command.
Note that the value is ignored as query groups themselves are not implemented.

Reference: <https://docs.aws.amazon.com/redshift/latest/dg/r_query_group.html>


### Additional tables

Redshift system tables are implemented in `00_stl_tables.sql` and `00_stv_tables.sql`.
Expect them to be empty, or include garbage data, but SELECTs won't necessarily fail.


### Additional functions

Additional functions are implemented as Python or SQL UDFs.
For a list, see `sql/01_functions.sql`.


## License

This project is dual-licensed under the MIT license and the PostgreSQL license.
You may choose whichever license suits your purpose best.
The full license texts are available in the `LICENSE` (MIT) and `LICENSE.PostgreSQL`
(PostgreSQL License) files.
