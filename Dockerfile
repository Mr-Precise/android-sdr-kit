FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV ENV="/etc/profile"

COPY install.sh /root
COPY build.sh /root
COPY package.sh /root

RUN chmod +x /root/install.sh && cd /root && ./install.sh

ENV JAVA_HOME=/opt/java
ENV ANDROID_HOME=/root/Android
ENV ANDROID_SDK_ROOT=/root/Android
ENV SDR_KIT_ROOT=/sdr-kit
ENV GRADLE_HOME=/opt/gradle/gradle-8.13
ENV PATH=/opt/java/bin:/opt/gradle/gradle-8.13/bin:/root/Android/cmdline-tools/latest/bin:/root/Android/platform-tools:${PATH}
