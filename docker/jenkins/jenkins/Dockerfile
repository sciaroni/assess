FROM jenkins:1.651.3
COPY install-plugins.sh /tmp/install-plugins.sh
USER root
RUN chmod +x /tmp/install-plugins.sh
RUN /tmp/install-plugins.sh deployit-plugin xlrelease-plugin maven-plugin git job-dsl chucknorris greenballs envinject gradle slack github view-job-filters copyartifact cloudbees-folder
COPY plugins.txt /tmp/plugins.txt
RUN /usr/local/bin/plugins.sh /tmp/plugins.txt
#233 is the docker gid under CoreOS, has to be added in the container so Jenkins can control the docker socket
RUN groupadd -g 233 docker && adduser jenkins docker
#Used for access on docker-machine
RUN adduser jenkins users

#To generate:
#1) ssh-keyscan -t dsa github.com > githubKey
#2) ssh-keygen -lf githubKey
#3) Compare fingerprints against https://help.github.com/articles/what-are-github-s-ssh-key-fingerprints/
#4) If they match the content of the githubKey file is what you should echo into known_hosts
ADD jenkins_start.sh /usr/local/bin/jenkins_start.sh
RUN chmod +x /usr/local/bin/jenkins_start.sh

ADD config.xml /tmp/config.xml
USER jenkins

ENTRYPOINT ["/usr/local/bin/jenkins_start.sh"]
