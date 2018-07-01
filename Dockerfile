FROM postgres:10

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	postgresql-server-dev-10 gcc make \
	python python3 python-dev python-pip python-setuptools python-wheel \
	postgresql-plpython-10 postgresql-plpython3-10

# Install Python 2 libraries native to Redshift. Versions available here:
# https://docs.aws.amazon.com/redshift/latest/dg/udf-python-language-support.html
# NOTE: pandas 0.18.1 instead of 0.14.1 due to lack of wheel for <0.18.1
RUN /usr/bin/python2.7 -m pip install \
	numpy==1.8.2 \
	pandas==0.18.1 \
	python-dateutil==2.2 \
	pytz==2015.7 \
	scipy==0.12.1 \
	six==1.3.0 \
	psycopg2==2.7.5
# wsgiref==0.1.2 (Installed by default)

# Compile query_group redshift compat extension
COPY "extensions/" "/tmp/extensions/"
RUN \
	make -C "/tmp/extensions/" && \
	make -C "/tmp/extensions/" install

# Install query_group extension
RUN \
	sed "/shared_preload_libraries/d" -i /usr/share/postgresql/postgresql.conf.sample && \
	echo "shared_preload_libraries = 'query_group'" >> /usr/share/postgresql/postgresql.conf.sample

# Clean up unused packages and temp files
RUN apt-get purge -y gcc make python-dev postgresql-server-dev-10 && \
	rm -r /tmp/extensions

COPY [ \
	"sql/00_extensions.sql", \
	"sql/00_stl_tables.sql", \
	"sql/00_stv_tables.sql", \
	"sql/01_functions.sql", \
	"/docker-entrypoint-initdb.d/"]

ENV POSTGRES_DB dev

EXPOSE 5432
