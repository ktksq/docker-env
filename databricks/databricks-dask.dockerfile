FROM databricksruntime/dbfsfuse:10.4-LTS

ARG ECC_INSTALL_PREFIX=/usr/local
ARG CMAKE_VERSION=3.20.2
ARG ECCODES_VERSION=2.22.0

USER root
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
            software-properties-common build-essential ca-certificates \
            git make wget unzip libtool automake wget openssl libssl-dev

RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh
RUN mkdir /opt/cmake
RUN /bin/sh ./cmake-${CMAKE_VERSION}-linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
RUN cmake --version

RUN wget https://confluence.ecmwf.int/download/attachments/45757960/eccodes-${ECCODES_VERSION}-Source.tar.gz && tar -xzf eccodes-${ECCODES_VERSION}-Source.tar.gz

ENV DEBUG true
ENV FC=gfortran
ENV CC=gcc

# Install script dependance avaible on apt source
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    build-essential \
    bzip2 \
    tar \
    amqp-tools \
    openssh-client \
    gfortran \
    --no-install-recommends && rm -r /var/lib/apt/lists/* \
    && wget ftp://ftp.cpc.ncep.noaa.gov/wd51we/wgrib2/wgrib2.tgz -O /tmp/wgrib2.tgz \
    && mkdir -p /usr/local/grib2/ \
    && tar -xf /tmp/wgrib2.tgz -C /tmp/ \
    && rm -r /tmp/wgrib2.tgz \
    && mv /tmp/grib2/ /usr/local/grib2/ \
    && cd /usr/local/grib2/grib2 && make \
    && ln -s /usr/local/grib2/grib2/wgrib2/wgrib2 /usr/local/bin/wgrib2 \
    && apt-get -y autoremove build-essential

VOLUME /srv/
VOLUME /opt/
WORKDIR /opt/
ENTRYPOINT [ "/bin/bash" ]
CMD ["/opt/entrypoint.sh"]

RUN mkdir build
WORKDIR build
RUN cmake -DCMAKE_INSTALL_PREFIX=${ECC_INSTALL_PREFIX} -DENABLE_FORTRAN=OFF ../eccodes-${ECCODES_VERSION}-Source
RUN make
RUN make install
RUN ldconfig
WORKDIR /
ADD requirements.txt .
RUN /databricks/python3/bin/pip install -r requirements.txt
RUN /databricks/python3/bin/pip install "dask[complete]"
RUN /databricks/python3/bin/python -m cfgrib selfcheck