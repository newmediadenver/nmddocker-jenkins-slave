FROM ubuntu:14.04

RUN echo "1.574" > .lts-version-number

RUN apt-get update && apt-get install -y wget git curl zip
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-7-jdk
RUN apt-get update && apt-get install -y maven=3.0.5-1 ant=1.9.3-2build1 ruby rbenv make

#add chef client to give access to install knife etc..
RUN cd /tmp/ && curl -O -L http://www.opscode.com/chef/install.sh
RUN cd /tmp/ && sudo /bin/sh install.sh

RUN wget -q -O - http://pkg.jenkins-ci.org/debian-stable/jenkins-ci.org.key | sudo apt-key add -
RUN echo deb http://pkg.jenkins-ci.org/debian-stable binary/ >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y jenkins
RUN apt-get install -y openssh-server && mkdir /var/run/sshd && rm /etc/nologin && sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd
RUN mkdir -p /var/jenkins_home && chown -R jenkins /var/jenkins_home
ADD init.groovy /tmp/WEB-INF/init.groovy
RUN cd /tmp && zip -g /usr/share/jenkins/jenkins.war WEB-INF/init.groovy

EXPOSE 22

USER jenkins
# VOLUME /var/jenkins_home - bind this in via -v if you want to make this persistent.
ENV JENKINS_HOME /var/jenkins_home

# for main web interface:
EXPOSE 8080

# will be used by attached slave agents:
EXPOSE 50000

USER root
