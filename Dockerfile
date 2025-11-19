FROM jenkins/inbound-agent:jdk21

USER root

# Install dependencies in one layer
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    ruby \
    ruby-dev \
    build-essential \
    git \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

# Install Fastlane
RUN gem install fastlane -NV

# Install Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    cd ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip -q commandlinetools-linux-9477386_latest.zip && \
    rm commandlinetools-linux-9477386_latest.zip && \
    mv cmdline-tools latest

# Accept licenses and install build tools
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "build-tools;33.0.0" "platforms;android-33"

USER jenkins
