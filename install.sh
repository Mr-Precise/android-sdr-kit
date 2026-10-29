set -e

# Clear any pre-set JAVA_HOME to prevent sdkmanager checking non-existent path
unset JAVA_HOME

# Settings
export ANDROID_INSTALLER=commandlinetools-linux-11076708_latest.zip
export ANDROID_API_LEVEL=28
export ANDROID_COMPILE_SDK=35
export ANDROID_BUILD_TOOLS=35.0.0
export ANDROID_NDK_VERSION=26.1.10909125
export ANDROID_CMAKE_VERSION=3.22.1
export GRADLE_VERSION=8.13
export SDR_KIT_BUILD=/root/sdr-kit-build
export SDR_KIT_ROOT=/sdr-kit
export MAKEOPTS=-j$(nproc)

# Install dependencies (explicitly openjdk-17-jdk)
apt update -y
apt install -y wget git p7zip-full unzip openjdk-17-jdk build-essential cmake patchelf python3-mako

# Detect Java 17 and create clean canonical symlink
JAVA_DETECTED=$(dirname $(dirname $(readlink -f $(which java))))
mkdir -p /opt
ln -sfn "$JAVA_DETECTED" /opt/java
export JAVA_HOME=/opt/java
export PATH=$JAVA_HOME/bin:$PATH

# Install the Android tools
mkdir -p Android/cmdline-tools
wget https://dl.google.com/android/repository/$ANDROID_INSTALLER
7z x $ANDROID_INSTALLER
mv cmdline-tools Android/cmdline-tools/latest
export ANDROID_HOME=/root/Android
export ANDROID_SDK_ROOT=/root/Android

# Accept licenses and install the SDK, NDK, platforms, build-tools, cmake
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME --licenses
yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --sdk_root=$ANDROID_HOME --install \
    "platforms;android-$ANDROID_API_LEVEL" \
    "platforms;android-$ANDROID_COMPILE_SDK" \
    "build-tools;$ANDROID_BUILD_TOOLS" \
    "ndk;$ANDROID_NDK_VERSION" \
    "cmake;$ANDROID_CMAKE_VERSION"
export ANDROID_NDK_TOOLCHAIN=$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION/toolchains/llvm/prebuilt/linux-x86_64/bin
export ANDROID_NDK_CMAKE=$ANDROID_HOME/ndk/$ANDROID_NDK_VERSION/build/cmake/android.toolchain.cmake

# Install gradle
mkdir -p /opt/gradle/
wget https://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip
7z x gradle-$GRADLE_VERSION-bin.zip
cp -r gradle-$GRADLE_VERSION /opt/gradle/
echo "export GRADLE_HOME=/opt/gradle/gradle-$GRADLE_VERSION" >> /etc/profile
echo "export PATH=\$GRADLE_HOME/bin:\$PATH" >> /etc/profile

# Create directories
mkdir -p $SDR_KIT_BUILD
mkdir -p $SDR_KIT_ROOT
echo "export SDR_KIT_ROOT=$SDR_KIT_ROOT" >> /etc/profile

# Do build
cd $SDR_KIT_BUILD
chmod +x /root/build.sh
chmod +x /root/package.sh
/root/build.sh

# Setup environment variables at launch
echo "export JAVA_HOME=/opt/java" >> /etc/profile
echo "export ANDROID_HOME=$ANDROID_HOME" >> /etc/profile
echo "export ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT" >> /etc/profile
echo "export ANDROID_NDK_VERSION=$ANDROID_NDK_VERSION" >> /etc/profile
echo "export PATH=/opt/java/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$PATH" >> /etc/profile
