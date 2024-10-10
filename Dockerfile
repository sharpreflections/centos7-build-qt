###############################################################################
# Parameters
###############################################################################

ARG gcc=gcc-8.3.1
ARG qt_major=5.12
ARG qt_minor=.12
ARG qt_string=qt-everywhere-src
ARG prefix=/opt
ARG suffix=${gcc}
ARG qt_prefix=/p/hpc/psp/Qt
ARG build_type=release

###############################################################################
# Base Image
###############################################################################

FROM quay.io/centos/centos:centos7 AS base

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

FROM centos7-build-base-patched AS builder

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
    libxkbcommon-devel \
    libxkbcommon-x11-devel \
    libXi-devel \
    libXrandr-devel \
    libXtst-devel \
    gperf \
    expat-devel \
    xkeyboard-config \
    nss-devel \
    devtoolset-8 \
    patch \
    xorg-x11-apps \      
\
&& echo "Downloading Qt5 ${qt_version}:" \
&& curl --remote-name --location --progress-bar \
    http://download.qt.io/archive/qt/${qt_major}/${qt_version}/single/${qt_string}-${qt_version}.tar.xz \
&& curl --remote-name --location --silent \
    http://download.qt.io/archive/qt/${qt_major}/${qt_version}/single/md5sums.txt \
\
 && echo -n "Verifying file.. " \
 && sed --in-place '/.*\.zip/d' md5sums.txt \
 && md5sum --quiet --check md5sums.txt \
 && echo "done" \
 \
 && echo -n "Extracting Qt5 ${qt_version} " \
 && tar -xf ${qt_string}-${qt_version}.tar.xz \
 && echo "done" \
 \
 && echo "Patch Qt5 ${qt_version}:" \
 && for patch in $(find "$(pwd)/patches/" -type f | sort -n); \
    do echo "-- Apply $(basename ${patch})." \
 &&    patch -d ${qt_string}-${qt_version} -p1 -i ${patch}; \
    done \
 && echo "done" \
#dock && source scl_source enable devtoolset-8 \
#dock && mkdir build \
#dock && cd build \
#dock && ../${qt_string}-${qt_version}/configure \
#dock      -opensource \
#dock      -confirm-license \
#dock      --prefix=${qt_prefix}/Qt-${qt_version}-$suffix/lib \
#dock      --libdir=${qt_prefix}/Qt-${qt_version}-$suffix/lib \
#dock      --bindir=${qt_prefix}/Qt-${qt_version}-$suffix/lib/bin \
#dock      --libexecdir=${qt_prefix}/Qt-${qt_version}-$suffix/lib/libexec \
#dock      --plugindir=${qt_prefix}/Qt-${qt_version}-$suffix/lib/plugins \
#dock      -shared \
#dock      -c++std c++14 \
#dock      -platform linux-g++-64 \
#dock      -${build_type} \
#dock      -no-pch \
#dock      -ssl \
#dock      -fontconfig \
#dock      -system-freetype \
#dock      -qt-zlib \
#dock      -qt-libjpeg \
#dock      -qt-libpng \
#dock      -qt-xcb \
#dock      -nomake examples \
#dock      -nomake tests \
#dock      -no-sse4.1 \
#dock      -no-sse4.2 \
#dock      -no-avx \
#dock      -no-avx2 \
#dock      -no-avx512 \
#dock      -no-rpath \
#dock      -no-dbus \
#dock      -no-cups \
#dock      -no-iconv \
#dock      -no-gtk \
#dock      -no-glib \
#dock      -no-icu \
#dock      -no-webrtc \
#dock      -no-pepper-plugins \
#dock      -no-spellchecker \
#dock      -no-printing-and-pdf \
#dock      -skip qt3d \
#dock      -skip qtactiveqt \
#dock      -skip qtandroidextras \
#dock      -skip qtcanvas3d \
#dock      -skip qtcharts \
#dock      -skip qtconnectivity \
#dock      -skip qtdatavis3d \
#dock      -skip qtgamepad \
#dock      -skip qtgraphicaleffects \
#dock      -skip qtimageformats \
#dock      -skip qtlocation \
#dock      -skip qtmacextras \
#dock      -skip qtmultimedia \
#dock      -skip qtnetworkauth \
#dock      -skip qtpurchasing \
#dock      -skip qtremoteobjects \
#dock      -skip qtsensors \
#dock      -skip qtserialbus \
#dock      -skip qtserialport \
#dock      -skip qtspeech \
#dock      -skip qttranslations \
#dock      -skip qtvirtualkeyboard \
#dock      -skip qtwayland \
#dock      -skip qtwebsockets \
#dock      -skip qtwinextras \ 
#dock# # Not skipping: qtbase
#dock# #               qtdeclarative
#dock# #               qtdoc
#dock# #               qtimageformats
#dock# #               qtquickcontrols  # required by qtwebengine
#dock# #               qtquickcontrols2
#dock# #               qtremoteobjects
#dock# #               qtscxml
#dock# #               qtscript
#dock# #               qtsvg
#dock# #               qttools
#dock# #               qtwebchannel     # required by qtwebengine
#dock# #               qtwebengine
#dock# #               qtwebview
#dock# #               qtx11extras
#dock# #               qtxmlpatterns
#dock#  \
#dock   && make --jobs=$(nproc) \
#dock   && make install
#dock
#dock###############################################################################
#dock# Final Image
#dock###############################################################################
#dock
#dockFROM base
#dock
#dockARG qt_prefix
#dock
#dockCOPY --from=builder ${qt_prefix} ${qt_prefix}
