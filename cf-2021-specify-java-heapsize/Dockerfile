FROM adobecoldfusion/coldfusion2021

# it's not possible (even as of CF2021 update 6) to leverage cfsetup to export/import its jvm category,
# and while some jvm settings can be set via _java_options env var, CF won't honor xmx or xms if changed that way
# so we must manually edit the jvm.config

# modify jvm.config java.home line to name this new path

# the following values increment the (current) default values by 1. 
ENV xms=257m
ENV xmx=1025m
# You can confirm the changed value within CF Admin, of course, or via java method in provided getheapsize.cfm

# while the value in the file is currently 256m, Adobe could change it in the future, so a regex is used instead

RUN sed -i \
    -e 's/-Xms[[:digit:]]\+[kmg ]/-Xms'"$xms"'/' \
    -e 's/-Xmx[[:digit:]]\+[kmg ]/-Xmx'"$xmx"'/' \
    /opt/coldfusion/cfusion/bin/jvm.config