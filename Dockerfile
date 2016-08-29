FROM michilu/fedora-zero
# Switch to dnf.
RUN yum install --setopt=rawhide.skip_if_unavailable=true --quiet -y dnf && dnf clean all
# Install commands.
# sudo needed by Wercker CI
RUN dnf update --quiet -y \
  && rpm --quiet --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-24-primary \
  && dnf install --quiet -y \
  coffee-script \
  findutils \
  git \
  npm \
  rsync \
  rubygem-bundler \
  rubygem-coffee-script \
  rubygem-compass \
  rubygem-haml \
  rubygem-sass \
  sudo \
  unzip \
  zip \
  && dnf clean all

# Export variables.
WORKDIR $HOME
ENV DART_SDK="${HOME}/dart-sdk" PATH="${PATH}:${HOME}/dart-sdk/bin" DART_VERSION="1.18.1"

# Install Dart SDK.
RUN dnf update --quiet -y \
  && curl --silent --remote-name "http://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-x64-release.zip" \
  && unzip -qq "dartsdk-linux-x64-release.zip" \
  && rm "dartsdk-linux-x64-release.zip"

# For test.
# Display installed versions.
#CMD test -d ${DART_SDK} || { ls -a ${HOME} ; echo "dart-sdk directory not found at ${DART_SDK}, terminating."; exit 1; } \
#  && type dart || { echo "PATH: ${PATH}"; echo "dart command not availble after installation, terminating."; exit 1; } \
#  && type pub || { echo "PATH: ${PATH}"; echo "pub command not availble after installation, terminating."; exit 1; } \
#  && echo "test: OK."
