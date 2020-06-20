FROM ubuntu:16.04

MAINTAINER CASTIRON <castiron@ibm.com>

ENV IRONHIDE_SOURCE /var/tmp/ironhide-setup

RUN apt-get update && apt-get install -y  openssh-server supervisor cron syslog-ng-core logrotate libapr1 libaprutil1 liblog4cxx10v5 libxml2 psmisc xsltproc ntp vim net-tools iputils-ping

RUN sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf

RUN sed -i 's/^su root syslog/su root adm/' /etc/logrotate.conf

ADD ironhide-setup/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/log/supervisor & mkdir -p /opt/ibm/

#Directory to hold the artifacts which need to be loaded during docker launch/start
RUN mkdir -p /var/tmp/LoadArtifacts/projects & mkdir -p /var/tmp/LoadArtifacts/ThirdPartylibs & mkdir -p /var/tmp/LoadArtifacts/SecureConnectorConfig
RUN mkdir -p /var/tmp/LoadArtifacts/UsersAndGroups & mkdir -p /var/tmp/LoadArtifacts/CertificatesAndKeys

COPY /ironhide-setup/etc/cron.d/* /etc/cron.d/

#copy the configuration files inside docker container
COPY /projects /var/tmp/LoadArtifacts/projects
COPY /UsersAndGroups /var/tmp/LoadArtifacts/UsersAndGroups
COPY /CertificatesAndKeys /var/tmp/LoadArtifacts/CertificatesAndKeys
COPY /ThirdPartylibs /var/tmp/LoadArtifacts/ThirdPartylibs
COPY /SecureConnectorConfig /var/tmp/LoadArtifacts/SecureConnectorConfig

COPY ironhide-setup/etc/logrotate.d/* /etc/logrotate.d/

RUN chmod 644 /etc/cron.d/*

ADD ironhide-setup $IRONHIDE_SOURCE

RUN chmod -R 777  $IRONHIDE_SOURCE

ENV JAVA_HOME /usr/java/default

ENV PATH $JAVA_HOME/bin:$PATH

ENV IRONHIDE_ROOT /usr/ironhide

ENV LD_LIBRARY_PATH /usr/ironhide/lib

ENV IH_ROOT /usr/ironhide

ENV IRONHIDE_BACKUP_PATH /var/tmp/ironhide-backup

ENV PATH $IH_ROOT/bin:$PATH

ENV interface1=""

ENV interface2=""

COPY ironhide-setup/scripts/liblog4cxx.so.10 /usr/lib/x86_64-linux-gnu/liblog4cxx.so.10.0.0

RUN echo 'PS1="[AppConnect-Container@\h \w]: "' >> ~/.bashrc

CMD ["/usr/bin/supervisord"]
