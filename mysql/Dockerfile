# Note: this is a copy of https://raw.githubusercontent.com/docker-library/mysql/master/5.6/Dockerfile, with the volume removed.

FROM debian:jessie

ENV MYSQL_MAJOR 5.6
ENV MYSQL_VERSION 5.6.31-1debian8

RUN groupadd -r mysql && \
    useradd -r -g mysql mysql && \
    mkdir /docker-entrypoint-initdb.d && \
    apt-get update && apt-get install -y perl pwgen --no-install-recommends && rm -rf /var/lib/apt/lists/* && \
    apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5 && \
    echo "deb http://repo.mysql.com/apt/debian/ jessie mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list && \
    { \
		echo mysql-community-server mysql-community-server/data-dir select ''; \
		echo mysql-community-server mysql-community-server/root-pass password ''; \
		echo mysql-community-server mysql-community-server/re-root-pass password ''; \
		echo mysql-community-server mysql-community-server/remove-test-db select false; \
  	} | debconf-set-selections && \
	  apt-get update && \
    apt-get install -y mysql-server="${MYSQL_VERSION}" && rm -rf /var/lib/apt/lists/* && \
	  rm -rf /var/lib/mysql && \
    mkdir -p /var/lib/mysql && \
    sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf && \
	  echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf && \
	  mv /tmp/my.cnf /etc/mysql/my.cnf

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]
