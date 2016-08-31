FROM mnubo/jre8:u91

ENV ELASTICSEARCH_VERSION 2.3.5
ENV ELASTICSEARCH_REPO_BASE http://packages.elasticsearch.org/elasticsearch/2.x/debian

# grab gosu for easy step-down from root
RUN apt-get install -y curl &&\
    gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 &&\
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture)" &&\
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$(dpkg --print-architecture).asc" &&\
    gpg --verify /usr/local/bin/gosu.asc &&\
    rm /usr/local/bin/gosu.asc &&\
    chmod +x /usr/local/bin/gosu &&\
    apt-key adv --keyserver pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4 &&\
    echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch.list &&\
    apt-get update &&\
    apt-get install -y elasticsearch=$ELASTICSEARCH_VERSION &&\
    rm -rf /var/lib/apt/lists/* &&\
    set -ex &&\
      for path in \
        /usr/share/elasticsearch/data \
        /usr/share/elasticsearch/logs \
        /usr/share/elasticsearch/config \
        /usr/share/elasticsearch/config/scripts \
    ; do \
        mkdir -p "$path"; \
        chown -R elasticsearch:elasticsearch "$path"; \
    done &&\
    /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/2.0 &&\
    /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head/2.0 &&\
    /usr/share/elasticsearch/bin/plugin install delete-by-query &&\
    apt-get clean all

ENV PATH /usr/share/elasticsearch/bin:$PATH
COPY config /usr/share/elasticsearch/config

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 9200 9300

CMD ["elasticsearch"]