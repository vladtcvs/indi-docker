FROM debian:bookworm AS indi-builder
RUN apt update && apt install -y --no-install-recommends --no-install-suggests make cmake gcc g++ pkg-config git && apt install -y libcfitsio-dev libfftw3-dev libgmock-dev libgtest-dev librtlsdr-dev libtheora-dev libogg-dev libvorbis-dev libjpeg-dev libgsl-dev libcurl4-openssl-dev libusb-1.0-0-dev libnova-dev libev-dev zlib1g-dev libgphoto2-dev libraw-dev libftdi1-dev libdc1394-dev libgps-dev libavcodec-dev libavdevice-dev libavformat-dev libzmq3-dev liblz4-dev

# build libXISF
WORKDIR /indi-build
RUN git clone https://gitea.nouspiro.space/nou/libXISF --depth 1
WORKDIR /indi-build/libXISF
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi -DUSE_BUNDLED_LZ4=OFF -DUSE_BUNDLED_ZLIB=OFF && make && make install

# build indi library
ARG LD_LIBRARY_PATH=/opt/indi/lib
WORKDIR /indi-build
RUN git clone https://github.com/indilib/indi.git --depth 1 --branch v2.1.0
WORKDIR /indi-build/indi
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi -DUDEVRULES_INSTALL_DIR=/opt/indi/udev-rules && make -j$(nproc) && make install

# download indi 3rd-party drivers
WORKDIR /indi-build
RUN git clone https://github.com/indilib/indi-3rdparty.git --depth 1 --branch v2.1.0

# install eqmod driver
FROM indi-builder AS indi-driver-eqmod
WORKDIR /indi-build/indi-3rdparty/indi-eqmod
RUN cmake . -DCMAKE_PREFIX_PATH=/opt/indi -DCMAKE_INSTALL_PREFIX=/opt/indi-eqmod -DINDI_DATA_DIR=/opt/indi-eqmod/share/indi && make && make install

# install svbony driver
FROM indi-builder AS indi-driver-svbony
WORKDIR /indi-build/indi-3rdparty/libsvbony
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-svbony -DUDEVRULES_INSTALL_DIR=/opt/indi-svbony/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/indi-svbony
RUN cmake . -DCMAKE_PREFIX_PATH=/opt/indi -DCMAKE_INSTALL_PREFIX=/opt/indi-svbony -DINDI_DATA_DIR=/opt/indi-svbony/share/indi && make && make install

# install toupbase driver
FROM indi-builder AS indi-driver-toupcam
WORKDIR /indi-build/indi-3rdparty/libtoupcam
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libomegonprocam
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libastroasis
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libtscam
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libmeadecam
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libnncam
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libbressercam
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libaltaircam
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libmallincam
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libogmacam
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/libstarshootg
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DUDEVRULES_INSTALL_DIR=/opt/indi-toupcam/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/indi-toupbase
RUN cmake . -DCMAKE_PREFIX_PATH=/opt/indi -DCMAKE_INSTALL_PREFIX=/opt/indi-toupcam -DINDI_DATA_DIR=/opt/indi-toupcam/share/indi && make && make install

# install QHY driver
FROM indi-builder AS indi-driver-qhy
WORKDIR /indi-build/indi-3rdparty/libqhy
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-qhy -DUDEVRULES_INSTALL_DIR=/opt/indi-qhy/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/indi-qhy
RUN cmake . -DCMAKE_PREFIX_PATH=/opt/indi -DCMAKE_INSTALL_PREFIX=/opt/indi-qhy -DINDI_DATA_DIR=/opt/indi-qhy/share/indi && make && make install

# install ZWO driver
FROM indi-builder AS indi-driver-zwo
WORKDIR /indi-build/indi-3rdparty/libasi
RUN cmake . -DCMAKE_INSTALL_PREFIX=/opt/indi-zwo -DUDEVRULES_INSTALL_DIR=/opt/indi-zwo/udev-rules && make install
WORKDIR /indi-build/indi-3rdparty/indi-asi
RUN cmake . -DCMAKE_PREFIX_PATH=/opt/indi -DCMAKE_INSTALL_PREFIX=/opt/indi-zwo -DINDI_DATA_DIR=/opt/indi-zwo/share/indi && make && make install

# indi web manager image
FROM debian:bookworm AS indiwebmanager
RUN apt update && apt install -y --no-install-recommends --no-install-suggests python3-minimal python3-importlib-metadata python3-psutil python3-requests python3-bottle python3-pip python3-setuptools git
WORKDIR /indi-build
RUN git clone https://github.com/knro/indiwebmanager.git --depth 1
WORKDIR /indi-build/indiwebmanager
RUN python3 setup.py build && python3 setup.py install

# create resulting image
FROM debian:bookworm as indi-basic
RUN apt update && apt install -y --no-install-recommends --no-install-suggests libev4 libnova-0.16-0 libusb-1.0-0 libfftw3-bin libfftw3-single3 libfftw3-double3 libfftw3-quad3 libfftw3-long3 libtheora0 libogg0 libcfitsio10 libjpeg62-turbo librtlsdr0 libgphoto2-6 libraw20 libgsl27 libftdi1-2 libgps28 usbutils python3-minimal python3-importlib-metadata python3-psutil python3-requests python3-bottle liblz4-1 && rm -rf /var/lib/apt/lists/*

COPY --from=indi-builder /opt/indi/ /opt/indi/
COPY --from=indiwebmanager /usr/local/lib/python3.11/dist-packages /usr/local/lib/python3.11/dist-packages
COPY --from=indiwebmanager /usr/local/bin/indi-web /opt/indi/bin/indi-web

ENV LD_LIBRARY_PATH=/opt/indi/lib
ENV PATH=$PATH:/opt/indi/bin
EXPOSE 7624 8624

WORKDIR /opt/indi/
ENTRYPOINT ["/opt/indi/bin/indi-web"]
CMD ["-x", "/opt/indi/share/indi"]
STOPSIGNAL SIGINT

# add drivers
FROM indi-basic as indi-full
COPY --from=indi-driver-svbony /opt/indi-svbony /opt/indi
COPY --from=indi-driver-toupcam /opt/indi-toupcam /opt/indi
COPY --from=indi-driver-qhy /opt/indi-qhy /opt/indi
COPY --from=indi-driver-zwo /opt/indi-zwo /opt/indi
COPY --from=indi-driver-eqmod /opt/indi-eqmod /opt/indi

# make archive with udev rules
WORKDIR /opt/indi/udev-rules
RUN tar cvf /opt/indi/rules.tar *
WORKDIR /opt/indi/

