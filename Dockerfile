FROM openshift/base-centos7

MAINTAINER JUN<junwsgj@gmail.com>

# TODO: Rename the builder environment variable to inform users about application you provide them
# ENV BUILDER_VERSION 1.0

# Copy extra files to the image.

ENV NODEJS_VERSION=8 \
    NPM_RUN=start \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH

ENV PUPPETEER_DOWNLOAD_HOST=https://storage.googleapis.com.cnpmjs.org

ENV SUMMARY="Platform for building and running Node.js $NODEJS_VERSION applications" \
    DESCRIPTION="Node.js $NODEJS_VERSION available as docker container is a base platform for \
building and running various Node.js $NODEJS_VERSION applications and frameworks. \
Node.js is a platform built on Chrome's JavaScript runtime for easily building \
fast, scalable network applications. Node.js uses an event-driven, non-blocking I/O model \
that makes it lightweight and efficient, perfect for data-intensive real-time applications \
that run across distributed devices."



LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Node.js $NODEJS_VERSION" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,nodejs,nodejs$NODEJS_VERSION" \
      com.redhat.dev-mode="DEV_MODE:false" \
      com.redhat.deployments-dir="/opt/app-root/src" \
      com.redhat.dev-mode.port="DEBUG_PORT:5858"\
      com.redhat.component="rh-nodejs8-docker" \
      name="centos/nodejs-8-centos7" \
      version="1" \
      maintainer="JUN <junwsgj@gmail.com>"


RUN yum update -y && \
    yum install pango.x86_64 libXcomposite.x86_64 libXcursor.x86_64 libXdamage.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 cups-libs.x86_64 libXScrnSaver.x86_64 libXrandr.x86_64 GConf2.x86_64 alsa-lib.x86_64 atk.x86_64 gtk3.x86_64 -y && \
    yum install ipa-gothic-fonts xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc  -y && \
    yum clean all

RUN yum install -y libnss3.so && yum clean all

# 安装nodejs
RUN cd /opt/app-root && \
    wget https://npm.taobao.org/mirrors/node/v8.9.1/node-v8.9.1-linux-x64.tar.xz && \
    tar vxf node-v8.9.1-linux-x64.tar.xz && \
    rm -rf node-v8.9.1-linux-x64.tar.xz

ENV PATH=/opt/app-root/node-v8.9.1-linux-x64/bin:$PATH

#安装yarn
RUN npm install -g cyarn --registry=https://registry.npm.taobao.org 

RUN cd /opt/app-root/src && cyarn init -y && cyarn add puppeteer

COPY ./s2i/bin/ /usr/libexec/s2i

# RUN echo `node -v` && echo `npm -v`

# set timze to "Asia/Shanghai"
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN chown -R 1001:1001 /opt/app-root && chmod -R ug+rwx /opt/app-root 

# RUN pwd && google-chrome --version


# This default user is created in the openshift/base-centos7 image
USER 1001

# TODO: Set the default port for applications built using this image
EXPOSE 8080

# TODO: Set the default CMD for the image
CMD ["/usr/libexec/s2i/usage"]
