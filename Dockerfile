FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN set -eux; \
	if [ -f /etc/dpkg/dpkg.cfg.d/docker ]; then \
# if this file exists, we're likely in "debian:xxx-slim", and locales are thus being excluded so we need to remove that exclusion (since we need locales)
		grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
		sed -ri '/\/usr\/share\/locale/d' /etc/dpkg/dpkg.cfg.d/docker; \
		! grep -q '/usr/share/locale' /etc/dpkg/dpkg.cfg.d/docker; \
	fi; \
	apt-get update; apt-get install -y locales; rm -rf /var/lib/apt/lists/*; \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# install "nss_wrapper" in case we need to fake "/etc/passwd" and "/etc/group" (especially for OpenShift)
# https://github.com/docker-library/postgres/issues/359
# https://cwrap.org/nss_wrapper.html

RUN apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates curl locales dirmngr gnupg gosu libnss-wrapper && \
	localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
	echo "debconf debconf/frontend select Noninteractive" | debconf-set-selections

# explicitly set user/group IDs
RUN gosu nobody true && \
	groupadd -r postgres --gid=999 && \
	useradd -r -g postgres --uid=999 postgres

ENV LANG=en_US.UTF-8 \
	LC_ALL=en_US.UTF-8 \
	PG_MAJOR=10 \
	PGDATA=/var/lib/postgresql/data

RUN key="B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8"; \
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	gpg --export "$key" > /etc/apt/trusted.gpg.d/postgres.gpg; \
	rm -rf "$GNUPGHOME" && \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main $PG_MAJOR" > /etc/apt/sources.list.d/pgdg.list; \
	echo "deb-src http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main $PG_MAJOR" >> /etc/apt/sources.list.d/pgdg.list; \
	apt-get update

RUN apt-get install -y postgresql-common postgresql-10 && \
	sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf

ENV PATH=$PATH:/usr/lib/postgresql/$PG_MAJOR/bin

# make the sample config easier to munge (and "correct by default")
RUN mv -v "/usr/share/postgresql/$PG_MAJOR/postgresql.conf.sample" /usr/share/postgresql/ \
	&& ln -sv ../postgresql.conf.sample "/usr/share/postgresql/$PG_MAJOR/" \
	&& sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/postgresql/postgresql.conf.sample

RUN mkdir /docker-entrypoint-initdb.d && \
	mkdir -p /var/run/postgresql && \
	chown -R postgres:postgres /var/run/postgresql && \
	chmod 2777 /var/run/postgresql && \
	mkdir -p "$PGDATA" && \
	chown -R postgres:postgres "$PGDATA" \
	&& chmod 777 "$PGDATA"

# recover docker-entrypoint.sh
RUN curl "https://raw.githubusercontent.com/docker-library/postgres/master/$PG_MAJOR/docker-entrypoint.sh" -o /usr/local/bin/docker-entrypoint.sh && \
	chmod +x /usr/local/bin/docker-entrypoint.sh && \
	ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat

### end postgres 10


RUN apt-get install -y --no-install-recommends \
	postgresql-server-dev-10 postgresql-plpython-10 postgresql-plpython3-10 \
	python2 python-dev  python-pip  python-setuptools  python-wheel  \
	python3 python3-dev python3-pip python3-setuptools python3-wheel


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
	psycopg2==2.7.5 \
	enum34==1.1.6
# wsgiref==0.1.2 (Installed by default)

RUN apt-get install -y --no-install-recommends make gcc

# Compile query_group redshift compat extension
COPY "extensions/" "/tmp/extensions/"
RUN make -C "/tmp/extensions/" && \
	make -C "/tmp/extensions/" install

# Install query_group extension
RUN sed "/shared_preload_libraries/d" -i /usr/share/postgresql/postgresql.conf.sample && \
	echo "shared_preload_libraries = 'query_group'" >> /usr/share/postgresql/postgresql.conf.sample

# Clean up unused packages and temp files
RUN rm -rf /var/lib/apt/lists/* && \
	apt-get purge -y gcc make python2-dev python3-dev postgresql-server-dev-10 curl gnupg dirmngr && \
	apt-get autoremove -y --purge && \
	rm -r /tmp/extensions

COPY [ \
	"sql/00_extensions.sql", \
	"sql/00_stl_tables.sql", \
	"sql/00_stv_tables.sql", \
	"sql/01_functions.sql", \
	"/docker-entrypoint-initdb.d/"]

ENV POSTGRES_DB dev

VOLUME /var/lib/postgresql/data
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 5432
CMD ["postgres"]
