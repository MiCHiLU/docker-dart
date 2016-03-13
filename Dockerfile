FROM michilu/fedora-zero
# Switch to dnf.
RUN yum install --setopt=rawhide.skip_if_unavailable=true --quiet -y dnf && dnf clean all
# Install commands.
# sudo needed by Wercker CI
# libX11.so.6 in libexif needed by google-chrome
# libudev.so.0 in systemd-devel needed by chromium
RUN dnf update --quiet -y \
  && rpm --quiet --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-24-primary \
  && dnf install --quiet -y \
  coffee-script \
  findutils \
  git \
  libexif \
  npm \
  rsync \
  rubygem-bundler \
  rubygem-coffee-script \
  rubygem-compass \
  rubygem-haml \
  rubygem-sass \
  sudo \
  systemd-devel \
  unzip \
  xorg-x11-server-Xvfb \
  zip \
  && dnf clean all \
  && mkdir /run/dbus \
  && (cd /usr/lib64 && ln -s libudev.so.1 libudev.so.0)

# Export variables.
WORKDIR $HOME
ENV DISPLAY=:99 DART_SDK="$HOME/dart-sdk" PATH="$PATH:$HOME/dart-sdk/bin" DART_VERSION="1.14.0"

# For chrome installation.
# Install Dart SDK and Dartium
ADD google-chrome.repo etc/yum.repos.d/
RUN dnf update --quiet -y \
  && dnf install --quiet -y \
  google-chrome-unstable \
  && dnf clean all \
  && curl --silent --remote-name "http://storage.googleapis.com/dart-archive/channels/stable/release/$DART_VERSION/sdk/dartsdk-linux-x64-release.zip" \
  && unzip -qq "dartsdk-linux-x64-release.zip" \
  && rm "dartsdk-linux-x64-release.zip" \
  && curl --silent --remote-name "http://storage.googleapis.com/dart-archive/channels/stable/release/$DART_VERSION/dartium/dartium-linux-x64-release.zip" \
  && unzip -qq "dartium-linux-x64-release.zip" \
  && mv `find . -name "dartium-lucid64-full-stable*" -type d|head -1` $HOME/chromium \
  && rm "dartium-linux-x64-release.zip"

# For test.
# Display installed versions.
#CMD test -d $DART_SDK || { ls -a $HOME ; echo "dart-sdk directory not found at $DART_SDK, terminating."; exit 1; } \
#  && type dart || { echo "PATH: $PATH"; echo "dart command not availble after installation, terminating."; exit 1; } \
#  && type pub || { echo "PATH: $PATH"; echo "pub command not availble after installation, terminating."; exit 1; } \
#  && echo "test: OK." \
#  && chromium/chrome --version \
#  && google-chrome --version \
#  && dbus-daemon --system --fork \
#  && xvfb-run google-chrome --disable-gpu
