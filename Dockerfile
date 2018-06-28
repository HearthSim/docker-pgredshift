FROM postgres:10

RUN apt-get update && \
	apt-get install -y python python3 make postgresql-server-dev-10 gcc

# Compile query_group redshift compat extension
COPY "extensions/" "/tmp/extensions/"
RUN \
	make -C "/tmp/extensions/" && \
	make -C "/tmp/extensions/" install

RUN \
	sed -i "s/#port = 5432/port = 5439/" /usr/share/postgresql/postgresql.conf.sample && \
	sed "/shared_preload_libraries/d" -i /usr/share/postgresql/postgresql.conf.sample && \
	echo "shared_preload_libraries = 'query_group'" >> /usr/share/postgresql/postgresql.conf.sample


EXPOSE 5439
