docker run --name ontrack1 -d -p 8444:8443 -p 9991:9990 -it --rm --env-file=app.env --privileged -v C:/Users/simars/jboss-eap-dev:/base:ro  fw/redhat-jboss-eap
docker run --name ontrack2 -d -p 8445:8443 -p 9992:9990 -it --rm --env-file=app.env --privileged -v C:/Users/simars/jboss-eap-dev:/base:ro  fw/redhat-jboss-eap
docker run --name ontrack3 -d -p 8446:8443 -p 9993:9990 -it --rm --env-file=app.env --privileged -v C:/Users/simars/jboss-eap-dev:/base:ro  fw/redhat-jboss-eap
