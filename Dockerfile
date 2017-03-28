# Version: 0.0.1
FROM ubuntu:trusty

MAINTAINER Celtec Tecnologia e Serviços "@celtec_tech"

ENV POSTGRES_PASSWD postgres
ENV POSTGRES_DATA_FOLDER /data

# Install dependencies
RUN apt-get update
RUN apt-get install -y build-essential gcc-4.7 python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev

RUN ["mkdir", "-p", "/usr/local/src/"]
ADD packages/postgresql-9.0.4.tar.gz /usr/local/src/
WORKDIR /usr/local/src/postgresql-9.0.4/

# Configure PostgreSQL
RUN ./configure --prefix=/usr/local --with-pgport=5432 --with-python --with-openssl --with-libxml --with-libxslt --with-zlib CC='gcc-4.7 -m64'
RUN ["make"]
RUN ["make", "install"]

WORKDIR /usr/local/src/postgresql-9.0.4/contrib
RUN ["make", "all"]
RUN ["make", "install"]

# Create postgres user in Ubuntu
RUN groupadd postgres
RUN useradd -r postgres -g postgres
RUN echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e

# Building libgeos v3.4.2
ADD packages/lib/geos-3.4.2.tar.bz2 /usr/local/src/
WORKDIR /usr/local/src/geos-3.4.2/
RUN ["./configure"]
RUN ["make"]
RUN ["make", "install"]

# Build libproj 4.8.0
ADD packages/lib/proj-4.8.0.tar.gz /usr/local/src/
WORKDIR /usr/local/src/proj-4.8.0/
RUN ["/bin/sh", "-c", "chown -R 142957:5000 /usr/local/src/proj-4.8.0/"]
RUN ./configure CC='gcc-4.7 -m64'
RUN ["make"]
RUN ["make", "install"]
RUN ["ldconfig"]

# Build PostGIS 1.5.8
ADD packages/postgis-1.5.3.tar.gz /usr/local/src/
WORKDIR /usr/local/src/postgis-1.5.3
RUN ./configure CC='gcc-4.7 -m64'
RUN make
RUN make install

# Postinstallation clean
WORKDIR /usr/local/
RUN rm -Rf src

# Configuration of database
RUN locale-gen en_US.UTF-8
RUN locale-gen pt_BR.UTF-8

EXPOSE 5432

# Volumes
VOLUME $POSTGRES_DATA_FOLDER

CMD su postgres -c 'postgres -D /data'
