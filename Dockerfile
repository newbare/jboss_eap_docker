FROM centos:6.7

MAINTAINER simars <simarpaulsingh@gmail.com>

RUN yum -y update;yum clean all

ARG DOWNLOAD_LINK=downloads
ENV DOWNLOAD_LINK=${DOWNLOAD_LINK}

# Install Java JDK

ARG java_rpm_filename=jdk-8u144-linux-x64.rpm
ENV java_rpm_filename=${java_rpm_filename}
ARG java_version=1.8.0_144
ENV java_version=${java_version}

ADD ${DOWNLOAD_LINK}/${java_rpm_filename} /tmp/jdk/
RUN rpm -Uvh /tmp/jdk/${java_rpm_filename} && \
    rm -f /tmp/jdk/${java_rpm_filename}

ENV JAVA_HOME /usr/java/jdk${java_version}

RUN mkdir -p /tmp/UnlimitedJCEPolicy
ADD ./jce-unlimited/US_export_policy.jar /tmp/UnlimitedJCEPolicy/US_export_policy.jar
ADD ./jce-unlimited/local_policy.jar     /tmp/UnlimitedJCEPolicy/local_policy.jar
RUN mv /tmp/UnlimitedJCEPolicy/*.*       $JAVA_HOME/jre/lib/security/
RUN rm -rf /tmp/UnlimitedJCEPolicy*

ADD ./trusted-root-ca/StaatderNederlandenRootCA-G2.pem     /tmp/StaatderNederlandenRootCA-G2.pem
RUN $JAVA_HOME/bin/keytool -import -noprompt -trustcacerts -alias StaatderNederlandenRootCA-G2 -file  /tmp/StaatderNederlandenRootCA-G2.pem -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit


# Install JBOSS
ENV INSTALLDIR=/home/jboss
ENV HOME /home/jboss

RUN groupadd -r jboss && useradd -r -g jboss -m -d $HOME jboss

RUN yum -y install zip unzip tar

USER jboss

ARG jboss_dist_filename=jboss-eap-6.4.0.zip
ENV jboss_dist_filename=${jboss_dist_filename}
ARG jboss_version=jboss-eap-6.4
ENV jboss_version=${jboss_version}

ARG jboss_patches_filename=jboss-patches.tar
ENV jboss_patches_filename=${jboss_patches_filename}

RUN echo "jboss_version=${jboss_version}, INSTALLDIR=${INSTALLDIR}" && \
   mkdir $INSTALLDIR/$jboss_version && \
   mkdir $INSTALLDIR/jboss-dist

USER root
ADD ${DOWNLOAD_LINK}/$jboss_dist_filename $INSTALLDIR/jboss-dist/
ADD ${DOWNLOAD_LINK}/$jboss_patches_filename $INSTALLDIR/jboss-dist/

RUN chown -R jboss:jboss $HOME
RUN chown -R jboss:jboss $INSTALLDIR
RUN find $HOME -type d -execdir chmod 770 {} \;
RUN find $HOME -type f -execdir chmod 660 {} \;

USER jboss

# Extract JBOSS
RUN test -f $INSTALLDIR/jboss-dist/$jboss_dist_filename \
    && (tar -xvf $INSTALLDIR/jboss-dist/$jboss_dist_filename  -C $INSTALLDIR/jboss-dist/ \
        || unzip $INSTALLDIR/jboss-dist/$jboss_dist_filename -d $INSTALLDIR/jboss-dist/) ;\
    rm -f $INSTALLDIR/jboss-dist/$jboss_dist_filename; \
    test -d $INSTALLDIR/jboss-dist/$jboss_version && \
    mv  $INSTALLDIR/jboss-dist/$jboss_version $HOME/.

ENV JBOSS_HOME=$HOME/$jboss_version

# Extract & apply JBOSS patches
RUN test -f $INSTALLDIR/jboss-dist/$jboss_patches_filename \
    && tar -xvf $INSTALLDIR/jboss-dist/$jboss_patches_filename -C $INSTALLDIR/jboss-dist/ \
    && rm -f $INSTALLDIR/jboss-dist/$jboss_patches_filename; \
    test -d $INSTALLDIR/jboss-dist/patches

RUN for f in $(ls -v $INSTALLDIR/jboss-dist/patches); do \
     echo "Apply patch $f" && $JBOSS_HOME/bin/jboss-cli.sh "patch apply $INSTALLDIR/jboss-dist/patches/$f" \
     && rm -rf $INSTALLDIR/jboss-dist/patches/$f; \
    done


USER root

RUN yum -y install curl
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64" \
    	&& chmod +x /usr/local/bin/gosu

RUN rm -rf $INSTALLDIR/jboss-dist

EXPOSE 22 5455 9999 8009 8080 8443 3528 3529 7500 45700 7600 57600 5445 23364 5432 8090 4447 4712 4713 9990 8787

RUN mkdir /etc/jboss-as
RUN mkdir /var/log/jboss/
RUN chown jboss:jboss /var/log/jboss/

RUN yum -y install dos2unix
COPY docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh && dos2unix /docker-entrypoint.sh

# entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["start-jboss"]
