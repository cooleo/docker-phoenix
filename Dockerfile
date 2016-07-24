FROM sequenceiq/hadoop-docker:2.7.0
MAINTAINER SequenceIQ

#java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
  
# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# zookeeper
ENV ZOOKEEPER_VERSION 3.4.6
RUN curl -s http://mirror.csclub.uwaterloo.ca/apache/zookeeper/zookeeper-$ZOOKEEPER_VERSION/zookeeper-$ZOOKEEPER_VERSION.tar.gz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s ./zookeeper-$ZOOKEEPER_VERSION zookeeper
ENV ZOO_HOME /usr/local/zookeeper
ENV PATH $PATH:$ZOO_HOME/bin
RUN mv $ZOO_HOME/conf/zoo_sample.cfg $ZOO_HOME/conf/zoo.cfg
RUN mkdir /tmp/zookeeper

# hbase
ENV HBASE_MAJOR 1.2

ENV HBASE_VERSION "1.2.2"
#RUN curl -s http://apache.mirror.gtcomm.net/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz | tar -xz -C /usr/local/
#RUN curl -s http://apache.mirror.gtcomm.net/hbase/1.2.2/hbase-1.2.2-bin.tar.gz | tar -xz -C /usr/local/
RUN curl -s http://apache.mirror.gtcomm.net/hbase/1.2.2/hbase-1.2.2-bin.tar.gz | tar -xz -C /usr/local

RUN cd /usr/local && ln -s ./hbase-$HBASE_VERSION hbase
ENV HBASE_HOME /usr/local/hbase
ENV PATH $PATH:$HBASE_HOME/bin
RUN rm /usr/local/hbase/conf/hbase-site.xml
ADD hbase-site.xml $HBASE_HOME/conf/hbase-site.xml

# phoenix
ENV PHOENIX_VERSION 4.7.0
#RUN curl -s http://apache.mirror.vexxhost.com/phoenix/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR/bin/phoenix-$PHOENIX_VERSION-HBase-$HBASE_MAJOR-bin.tar.gz | tar -xz -C /usr/local/
RUN curl -s http://www-eu.apache.org/dist/phoenix/phoenix-4.7.0-HBase-1.1/bin/phoenix-4.7.0-HBase-1.1-bin.tar.gz | tar -xz -C /usr/local/

RUN cd /usr/local && ln -s ./phoenix-4.7.0-HBase-1.1-bin phoenix
ENV PHOENIX_HOME /usr/local/phoenix
ENV PATH $PATH:$PHOENIX_HOME/bin
RUN cp /usr/local/phoenix/phoenix-core-4.7.0-HBase-1.1.jar /usr/local/hbase/lib/phoenix.jar
RUN cp /usr/local/phoenix/phoenix-server-4.7.0-HBase-1.1.jar /usr/local/hbase/phoenix-server.jar

# bootstrap-phoenix
ADD bootstrap-phoenix.sh /etc/bootstrap-phoenix.sh
RUN chown root:root /etc/bootstrap-phoenix.sh
RUN chmod 700 /etc/bootstrap-phoenix.sh

CMD ["/etc/bootstrap-phoenix.sh", "-bash"]

EXPOSE 8765
