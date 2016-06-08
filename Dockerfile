FROM jenkinsci/jenkins

USER root

###############################################################
# Docker in Docker https://github.com/jpetazzo/dind 
    
# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Install the magic wrapper.
ADD wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker

#
###############################################################

RUN apt-get update && apt-get install -y apparmor apache2-utils

COPY workflow-reg-proxy.conf /tmp/files/regup/workflow-reg-proxy.conf

COPY gen-security-data.sh /usr/local/bin/gen-security-data.sh
RUN chmod a+x /usr/local/bin/gen-security-data.sh
RUN /usr/local/bin/gen-security-data.sh /tmp/files/regup/sec

COPY run-demo.sh /usr/local/bin/run-demo.sh

COPY plugins.txt /tmp/files/
RUN /usr/local/bin/plugins.sh /tmp/files/plugins.txt
RUN touch /usr/share/jenkins/ref/plugins/credentials.jpi.pinned

COPY run.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/run.sh 

USER jenkins
CMD /usr/local/bin/run.sh

USER root
EXPOSE 8080 8081 9418

# wrapdocker has been modified to launch Jenkins via the installed run.sh script
CMD ["wrapdocker"]
