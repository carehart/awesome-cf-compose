FROM adobecoldfusion/coldfusion2021:latest

# it's not possible (even as of CF2021 update 5) to leverage cfsetup to export/import its jvm category, so must enable jvm settings via config below

# obtain Oracle jdk11 from CF downloads page, https://helpx.adobe.com/coldfusion/kb/coldfusion-downloads.html#third_party

RUN wget --no-check-certificate https://cfdownload.adobe.com/pub/adobe/coldfusion/java/java11/java11017/jdk-11.0.17_linux-x64_bin.deb
# will be slow on first call to wget, for a given jdk version

RUN apt-get update && \
    apt-get install -y ./jdk-11.0.17_linux-x64_bin.deb && \
    apt-get clean;

# which installs into /usr/lib/jvm/jdk-11/


# obtain latest open jdk11 over the web, install it within CF image
#RUN apt-get update && \
#    apt-get install -y openjdk-11-jdk && \
#    apt-get clean;

# which installs into /usr/lib/jvm/java-11-openjdk-amd64/

# could instead pull down java to host and copy it into image at some particular location with COPY command

# set env var to path where that Java is installed
ENV javaloc=/usr/lib/jvm/jdk-11/

# modify jvm.config java.home line to name this new path
RUN sed -i -e 's|^\(java.home=\).*|\1\'"$javaloc"'|' \
/opt/coldfusion/cfusion/bin/jvm.config