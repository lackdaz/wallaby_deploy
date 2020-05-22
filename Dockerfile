ARG GITHUB_URL_PATH=https://github.com/lackdaz/wallaby/blob/master/extras
ARG OPEN_CV_BUILDFILE=OpenCV-4.1.1-dirty-aarch64.sh
FROM nvcr.io/nvidia/l4t-base:r32.3.1 as base

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/src

RUN apt-get update && apt-get install -y --no-install-recommends make g++

FROM nvcr.io/nvidia/l4t-base:r32.3.1 as develop

WORKDIR /app

RUN apt update && apt install -y build-essential python3 python3-pip python3-dev python-dev python-pip python3-wheel \
    libgstreamer1.0-dev \
    ffmpeg \
    curl git \
    libopenblas-base mlocate && \
    sudo updatedb


## FFMPEG - COMPILING FROM SOURCE WITH HARDWARE ACCELERATION (BROKEN)
# RUN git clone https://github.com/jocover/jetson-ffmpeg.git /tmp/jetson-ffmpeg && mkdir /tmp/jetson-ffmpeg/build
# WORKDIR /tmp/jetson-ffmpeg/build
# RUN cmake .. 
# RUN make && sudo make install && sudo ldconfig
# RUN git clone git://source.ffmpeg.org/ffmpeg.git -b release/4.2 --depth=1 /tmp/ffmpeg \
#     && wget -P /tmp/ffmpeg https://github.com/jocover/jetson-ffmpeg/raw/master/ffmpeg_nvmpi.patch
# WORKDIR /tmp/ffmpeg
# RUN git apply ffmpeg_nvmpi.patch && ./configure --enable-nvmpi && make
# WORKDIR /app

RUN wget https://github.com/lackdaz/wallaby_deploy/blob/master/numpy-1.18.4-cp36-cp36m-linux_aarch64.whl?raw=true -O /tmp/numpy-1.18.4-cp36-cp36m-linux_aarch64.whl	
RUN wget https://github.com/lackdaz/wallaby_deploy/blob/master/torch-1.4.0-cp36-cp36m-linux_aarch64.whl?raw=true -O /tmp/torch-1.4.0-cp36-cp36m-linux_aarch64.whl


# FLASK
COPY ./requirements.txt .
RUN python3 -m pip install -U pip && python3 -m pip install -r requirements.txt


RUN apt-get update && \
    apt-get -y install python3 python3-pip python3-dev python-dev python-pip \
    python3-wheel python3-numpy python3-scipy python-numpy \ 
    build-essential cmake pkg-config \
    # for pytorch
    libopenblas-base libopenmpi-dev \
    # for opencv
    libjpeg-dev libpng-dev libtiff-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev \
    qt5-default \
    mlocate


# NUMPY AND PYTORCH
RUN python3 -m pip install -U pip \
    && python3 -m pip install cython \
    && python3 -m pip install future /tmp/numpy-1.18.4-cp36-cp36m-linux_aarch64.whl /tmp/torch-1.4.0-cp36-cp36m-linux_aarch64.whl


# OPENCV
RUN wget -P /tmp/ https://media.githubusercontent.com/media/lackdaz/wallaby_deploy/master/OpenCV-4.1.1-dirty-aarch64.sh && chmod +x /tmp/OpenCV-4.1.1-dirty-aarch64.sh
RUN /tmp/OpenCV-4.1.1-dirty-aarch64.sh --prefix=/usr/local/ --skip-license \
    && sudo ldconfig \
    && sudo updatedb


RUN rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && rm -r /tmp/*


CMD ["python3", "app.py"]

# COPY --from=base /usr/src/test-launch /usr/src/test-launch

# COPY ./scripts/start.sh ./scripts/start.sh
# RUN chmod +x ./scripts/start.sh
# CMD "/usr/src/scripts/start.sh"

