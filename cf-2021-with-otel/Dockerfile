FROM adobecoldfusion/coldfusion2021:latest

RUN mkdir -p /opt/otelagent

COPY ./agent /opt/otelagent/

ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.3.0/opentelemetry-javaagent.jar /opt/otelagent/opentelemetry-javaagent.jar

RUN chmod -R o=rwx /opt/otelagent/