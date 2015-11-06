FROM java:openjdk-7-jre
MAINTAINER Discovery Dev <adsdiscoveryteam@pillartechnology.com>

ENV SONARQUBE_HOME /opt/sonarqube

RUN echo "deb http://downloads.sourceforge.net/project/sonar-pkg/deb binary/" >> /etc/apt/sources.list
RUN apt-get update && apt-get clean ### Sonar version 5.1 - timestamp

RUN apt-get install -y --force-yes sonar=5.1

COPY assets/init /app/init
RUN chmod 755 /app/init

VOLUME /opt/sonar/extensions
VOLUME /opt/sonar/logs/

COPY sonar-objective-c-plugin-0.4.0.jar $SONARQUBE_HOME/extensions/plugins/

ENTRYPOINT ["/app/init"]
CMD ["app:start"]
