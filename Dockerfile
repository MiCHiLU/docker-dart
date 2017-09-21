FROM michilu/docker-web-essentials

ENV PATH="${PATH}:${HOME}/dart-sdk/bin"

# https://github.com/frol/docker-alpine-glibc/blob/master/Dockerfile
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.25-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \
        "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

RUN apk --no-cache --update add \
  zip \
  ;

RUN dart_version="1.24.2" \
  ; curl --silent --remote-name "https://storage.googleapis.com/dart-archive/channels/stable/release/${dart_version}/sdk/dartsdk-linux-x64-release.zip" \
  && apk add --no-cache --virtual=.build-dependencies unzip \
  && unzip -qq "dartsdk-linux-x64-release.zip" \
  && apk del .build-dependencies \
  && rm "dartsdk-linux-x64-release.zip" \
  ;

CMD test -d ${HOME}/dart-sdk || { ls -a ${HOME} ; echo "dart-sdk directory not found at ${HOME}/dart-sdk, terminating."; exit 1; } \
  && type dart && dart --version || { echo "PATH: ${PATH}"; echo "dart command not availble after installation, terminating."; exit 1; } \
  && type pub && pub --version || { echo "PATH: ${PATH}"; echo "pub command not availble after installation, terminating."; exit 1; } \
  && echo "test: OK."
