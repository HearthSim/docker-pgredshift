FROM postgres:10

RUN apt-get update && \
	apt-get install -y python python3

RUN sed -i "s/#port = 5432/port = 5439/" /usr/share/postgresql/postgresql.conf.sample

EXPOSE 5439
