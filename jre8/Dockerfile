FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV JRE_MINOR_VERSION 91
ENV JAVA_HOME /opt/jre/jre1.8.0_$JRE_MINOR_VERSION

RUN apt-get update && \
    apt-get install -y wget && \
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u$JRE_MINOR_VERSION-b14/jre-8u$JRE_MINOR_VERSION-linux-x64.tar.gz && \
    mkdir /opt/jre && \
    tar -vzxf jre-8u$JRE_MINOR_VERSION-linux-x64.tar.gz -C /opt/jre && \
    ls -lad /opt/jre/* && \
    update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 100 && \
    rm jre-8u$JRE_MINOR_VERSION-linux-x64.tar.gz && \
    apt-get -y remove wget && \
    apt-get clean all

ENTRYPOINT ["java"]

CMD ["-version"]
