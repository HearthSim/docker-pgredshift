# docker-pgredshift

A docker image based on the [postgres image](https://hub.docker.com/_/postgres/)
which simulates an [AWS Redshift](https://aws.amazon.com/redshift/) instance.


## Postgres extension

The `query_group` extension adds support for the `SET query_group to ...` command.
Postgres does not allow setting unknown variables, so including that extension
prevents an error when issuing the command.
Note that the value is ignored as query groups themselves are not implemented.

Reference: <https://docs.aws.amazon.com/redshift/latest/dg/r_query_group.html>


## License

This project is licensed under the MIT license. The full license text is available in the LICENSE file.

