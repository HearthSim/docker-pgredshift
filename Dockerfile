FROM postgres:10

RUN apt-get update && \
	apt-get install -y \
	python python3 postgresql-server-dev-10 postgresql-plpython-10 postgresql-plpython3-10 gcc make

# Compile query_group redshift compat extension
COPY "extensions/" "/tmp/extensions/"
RUN \
	make -C "/tmp/extensions/" && \
	make -C "/tmp/extensions/" install

# Install query_group extension
RUN \
	sed "/shared_preload_libraries/d" -i /usr/share/postgresql/postgresql.conf.sample && \
	echo "shared_preload_libraries = 'query_group'" >> /usr/share/postgresql/postgresql.conf.sample

COPY [ \
	"sql/00_extensions.sql", \
	"sql/00_stl_tables.sql", \
	"sql/00_stv_tables.sql", \
	"sql/01_functions.sql", \
	"/docker-entrypoint-initdb.d/"]

ENV POSTGRES_DB dev

EXPOSE 5432
