FROM ubuntu:bionic

RUN apt-get update && apt-get install -y \
  software-properties-common && \
  add-apt-repository -y ppa:alex-p/tesseract-ocr && \
  apt-get remove -y software-properties-common && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
  locales \
  bc \
  bsdmainutils \
  unzip \
  poppler-utils \
  mediainfo \
  tesseract-ocr \
  tesseract-ocr-spa \
  libimage-exiftool-perl \
  libpcre2-dev \ 
  libpcre2-8-0 \
  python3 \
  python3-opencv \
  jq \
  imagemagick-6.q16 && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean

RUN apt-get update && apt-get install -y \
  build-essential bison flex && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean


RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

RUN mkdir galiasdoc

COPY . ./galiasdoc

RUN make -C galiasdoc

RUN cp -r galiasdoc/dist /app

CMD ["/bin/bash"]
