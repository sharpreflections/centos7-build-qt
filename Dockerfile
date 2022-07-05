###############################################################################
# Parameters
###############################################################################

ARG gcc=gcc-8.3.1
ARG qt_major=5.12
ARG qt_minor=.0
ARG qt_string=qt-everywhere-src
ARG prefix=/opt
ARG suffix=${gcc}
ARG qt_prefix=/p/hpc/psp/Qt
ARG build_type=release

###############################################################################
# Base Image
###############################################################################

FROM centos7-build-base as base

ARG gcc
ARG qt_major
ARG qt_minor
ARG qt_string
ARG prefix
ARG suffix
ARG qt_prefix
ARG build_type

###############################################################################
# Builder Image
###############################################################################

FROM base as builder

ARG gcc
ARG qt_major
ARG qt_minor
ARG qt_string
ARG prefix
ARG suffix
ARG qt_prefix
ARG build_type

ARG qt_version=${qt_major}${qt_minor}

COPY patches /build/patches/

ENV CC=gcc \
    CXX=g++

RUN yum -y install \
      python \
      binutils \
      xz \
      glibc-devel \
      bison \
      flex \
      make \
      mesa-libGL-devel \
      mesa-libEGL-devel \
      openssl-devel \
      fontconfig-devel \
      dbus-devel \
      libXcomposite-devel \
      libXcursor-devel \
      # libxkbcommon-devel \
      libXi-devel \
      libXrandr-devel \
      libXtst-devel \
      gperf \
      expat-devel \
      xkeyboard-config \
      nss-devel \
      devtoolset-8 \
      patch \
 \
 && echo "Downloading Qt5 ${qt_version}:" \
 && curl --remote-name --location --progress-bar \
      http://download.qt.io/official_releases/qt/${qt_major}/${qt_version}/single/${qt_string}-${qt_version}.tar.xz \
 && curl --remote-name --location --silent \
      http://download.qt.io/official_releases/qt/${qt_major}/${qt_version}/single/md5sums.txt \
 \
 && echo "Verifying file.." \
 && sed --in-place '/.*\.zip/d' md5sums.txt \
 && md5sum --quiet --check md5sums.txt \
 && echo " done" \
 \
 && echo -n "Extracting Qt5 ${qt_version}" \
 && tar -xf ${qt_string}-${qt_version}.tar.xz \
 && echo " done" \
 \
 && echo "Patch Qt5 ${qt_version}:" \
 && for patch in $(find "$(pwd)/patches/" -type f | sort -n); \
    do echo "-- Apply $(basename ${patch})." \
 &&    patch -d ${qt_string}-${qt_version} -p1 -i ${patch}; \
    done \
 && echo "done" \
 \
 && source scl_source enable devtoolset-8 \
 && mkdir build \
 && cd build \
 && ../${qt_string}-${qt_version}/configure \
      -opensource \
      -confirm-license \
      --prefix=${qt_prefix}/Qt-${qt_version}-$suffix/lib \
      --libdir=${qt_prefix}/Qt-${qt_version}-$suffix/lib \
      --bindir=${qt_prefix}/Qt-${qt_version}-$suffix/lib/bin \
      --libexecdir=${qt_prefix}/Qt-${qt_version}-$suffix/lib/libexec \
      --plugindir=${qt_prefix}/Qt-${qt_version}-$suffix/lib/plugins \
      -shared \
      -c++std c++14 \
      -platform linux-g++-64 \
      -${build_type} \
      -no-pch \
      -ssl \
      -fontconfig \
      -system-freetype \
      -qt-zlib \
      -qt-libjpeg \
      -qt-libpng \
      -qt-xcb \
      -qt-xkbcommon-x11 \
      -nomake examples \
      -nomake tests \
      -no-sse4.1 \
      -no-sse4.2 \
      -no-avx \
      -no-avx2 \
      -no-avx512 \
      -no-rpath \
      -no-dbus \
      -no-cups \
      -no-iconv \
      -no-gtk \
      -no-glib \
      -no-icu \
      -no-webrtc \
      -no-pepper-plugins \
      -no-spellchecker \
      -no-printing-and-pdf \
      -skip qt3d \
      -skip qtactiveqt \
      -skip qtandroidextras \
      -skip qtcanvas3d \
      -skip qtcharts \
      -skip qtconnectivity \
      -skip qtdatavis3d \
      -skip qtgamepad \
      -skip qtgraphicaleffects \
      -skip qtimageformats \
      -skip qtlocation \
      -skip qtmacextras \
      -skip qtmultimedia \
      -skip qtnetworkauth \
      -skip qtpurchasing \
      -skip qtremoteobjects \
      -skip qtsensors \
      -skip qtserialbus \
      -skip qtserialport \
      -skip qtspeech \
      -skip qttranslations \
      -skip qtvirtualkeyboard \
      -skip qtwayland \
      -skip qtwebsockets \
      -skip qtwinextras \
# Not skipping: qtbase
#               qtdeclarative
#               qtdoc
#               qtimageformats
#               qtquickcontrols  # required by qtwebengine
#               qtquickcontrols2
#               qtremoteobjects
#               qtscxml
#               qtscript
#               qtsvg
#               qttools
#               qtwebchannel     # required by qtwebengine
#               qtwebengine
#               qtwebview
#               qtx11extras
#               qtxmlpatterns
 \
 && make --jobs=$(nproc) \
 && make install

###############################################################################
# Final Image
###############################################################################

FROM base

ARG qt_prefix

COPY --from=builder ${qt_prefix} ${qt_prefix}
