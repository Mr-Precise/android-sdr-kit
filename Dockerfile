FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive
ENV ENV="/etc/profile"

ENV ANDROID_HOME=/root/Android
ENV ANDROID_SDK_ROOT=/root/Android
ENV SDR_KIT_ROOT=/sdr-kit
ENV GRADLE_HOME=/opt/gradle/gradle-8.13
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=/opt/gradle/gradle-8.13/bin:/root/Android/cmdline-tools/latest/bin:/root/Android/platform-tools:${PATH}

COPY install.sh /root
COPY build.sh /root
COPY package.sh /root

RUN chmod +x /root/install.sh && cd /root && ./install.sh
