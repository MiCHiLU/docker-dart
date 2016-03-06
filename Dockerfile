FROM michilu/fedora-zero
# Switch to dnf
RUN yum install --setopt=rawhide.skip_if_unavailable=true --quiet -y dnf && dnf clean all
# Install commands
RUN dnf install --quiet -y \
  unzip \
  && dnf clean all
# Export variables
WORKDIR $HOME
ENV DART_SDK="$HOME/dart-sdk" PATH="$PATH:$HOME/dart-sdk/bin" DART_VERSION="1.14.0"
# Install Dart SDK
RUN curl --silent --remote-name "http://storage.googleapis.com/dart-archive/channels/stable/release/$DART_VERSION/sdk/dartsdk-linux-x64-release.zip" \
  && unzip -qq "dartsdk-linux-x64-release.zip" \
  && rm "dartsdk-linux-x64-release.zip"
# TEST
RUN test -d $DART_SDK || { ls -a $HOME ; echo "dart-sdk directory not found at $DART_SDK, terminating."; exit 1; } \
  && type dart || { echo "PATH: $PATH"; echo "dart command not availble after installation, terminating."; exit 1; } \
  && type pub || { echo "PATH: $PATH"; echo "pub command not availble after installation, terminating."; exit 1; } \
  && echo "test: OK."
