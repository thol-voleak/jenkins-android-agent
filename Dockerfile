FROM jenkins/inbound-agent:jdk21

USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    ruby \
    ruby-dev \
    build-essential \
    git \
    wget \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Bundler and Fastlane globally
RUN gem install bundler fastlane -N

# Install Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    cd ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip -q commandlinetools-linux-9477386_latest.zip && \
    rm commandlinetools-linux-9477386_latest.zip && \
    mv cmdline-tools latest

# Accept licenses and install Android build tools
RUN yes | sdkmanager --licenses && \
    sdkmanager \
    "platform-tools" \
    "build-tools;33.0.0" \
    "build-tools;34.0.0" \
    "platforms;android-33" \
    "platforms;android-34"

# Pre-install Gradle
ENV GRADLE_VERSION=8.7
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    unzip -q gradle-${GRADLE_VERSION}-bin.zip -d /opt && \
    rm gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/bin/gradle

# Also cache Gradle 8.5 for wrapper
RUN mkdir -p /opt/gradle-cache && \
    cd /opt/gradle-cache && \
    wget -q https://services.gradle.org/distributions/gradle-8.5-bin.zip && \
    unzip -q gradle-8.5-bin.zip && \
    rm gradle-8.5-bin.zip

ENV GRADLE_HOME=/opt/gradle-${GRADLE_VERSION}
ENV PATH=${PATH}:${GRADLE_HOME}/bin

# Set gem paths
ENV GEM_HOME=/home/jenkins/.gems
ENV BUNDLE_PATH=/home/jenkins/.bundle
ENV PATH=${GEM_HOME}/bin:${PATH}

# Create directories and set permissions
RUN mkdir -p /home/jenkins/.gems /home/jenkins/.bundle /home/jenkins/.gradle && \
    chown -R jenkins:jenkins /home/jenkins

USER jenkins
