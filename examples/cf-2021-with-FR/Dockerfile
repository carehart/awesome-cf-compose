FROM adobecoldfusion/coldfusion2021:latest

RUN mkdir -p /opt/fusionreactor

ADD https://download.fusionreactor.io/FR/Latest/fusionreactor.jar /opt/fusionreactor/fusionreactor.jar
ADD https://download.fusionreactor.io/FR/Latest/libfrjvmti_x64.so /opt/fusionreactor/libfrjvmti_x64.so

# i found that FR would not start unless I made this permissions change
RUN chmod -R o=rwx /opt/fusionreactor/