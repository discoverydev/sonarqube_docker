FROM ubuntu:14.04
MAINTAINER Discovery Dev <adsdiscoveryteam@pillartechnology.com>

ENV POSTGRESQL_USER=sonar
ENV POSTGRESQL_PASS=xaexohquaetiesoo
ENV POSTGRESQL_DB=sonar
ENV DB_USER=sonar
ENV DB_PASS=xaexohquaetiesoo
ENV DB_NAME=sonar
ENV SONARQUBE_HOME /opt/sonarqube


RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN apt-get -qq update
RUN sudo apt-get install -y --force-yes openjdk-7-jre

RUN apt-get -qq update && DEBIAN_FRONTEND=noninteractive apt-get install -y -q postgresql-9.3 postgresql-contrib-9.3 postgresql-9.3-postgis-2.1 libpq-dev sudo


# /etc/ssl/private can't be accessed from within container for some reason
# (@andrewgodwin says it's something AUFS related)
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private

ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf
ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/9.3/main/*.conf
ADD run /usr/local/bin/run
RUN chmod +x /usr/local/bin/run

VOLUME ["/var/lib/postgresql"]
EXPOSE 5432

RUN echo "deb http://downloads.sourceforge.net/project/sonar-pkg/deb binary/" >> /etc/apt/sources.list
RUN apt-get update && apt-get clean ### Sonar version 5.1 - timestamp

RUN apt-get install -y --force-yes sonar=5.1

COPY assets/init /app/init
RUN chmod 755 /app/init

VOLUME /opt/sonar/extensions
VOLUME /opt/sonar/logs/

COPY sonar-objective-c-plugin-0.4.0.jar $SONARQUBE_HOME/extensions/plugins/
RUN rm -rf /opt/sonar/conf/sonar.properties
COPY sonar.properties /opt/sonar/conf/
EXPOSE 9000
EXPOSE 443
CMD ["/usr/local/bin/run &; /app/init app:start"]

