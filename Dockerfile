FROM postgres:10

RUN apt-get update && \
	apt-get install -y python python3 make postgresql-server-dev-10 gcc

# Compile query_group redshift compat extension
COPY "extensions/" "/tmp/extensions/"
RUN \
	make -C "/tmp/extensions/" && \
	make -C "/tmp/extensions/" install

# Install query_group extension
RUN \
	sed "/shared_preload_libraries/d" -i /usr/share/postgresql/postgresql.conf.sample && \
	echo "shared_preload_libraries = 'query_group'" >> /usr/share/postgresql/postgresql.conf.sample

# Change port to 5439
RUN \
	sed -i "s/#port = 5432/port = 5439/" /usr/share/postgresql/postgresql.conf.sample && \
	sed -i "s/psql -v ON_ERROR_STOP=1/psql -v ON_ERROR_STOP=1 --port=5439/" /docker-entrypoint.sh

COPY [ \
	"sql/00_functions.sql", \
	"sql/00_stl_tables.sql", \
	"sql/00_stv_tables.sql", \
	"sql/00_system.sql", \
	"/docker-entrypoint-initdb.d/"]

EXPOSE 5439
