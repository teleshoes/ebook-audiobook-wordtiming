#!/bin/sh
if [ -z $PREFIX ]; then
  PREFIX=/usr/bin
fi
if [ -z $VOSK_VENV ]; then
  VOSK_VENV=/opt/python-vosk
fi
if [ -z $COOLREADER_GIT_URL ]; then
  COOLREADER_GIT_URL="https://github.com/teleshoes/coolreader"
fi


if [ "$USER" != "root" ] || [ "$HOME" != "/root" ]; then
  echo "ERROR: run with 'sudo -H'"
  exit 1
fi


echo "\n\n\n### install ebook-audiobook-wordtiming + vosk-words-json"
cp src/vosk-words-json $PREFIX/
cp src/ebook-audiobook-wordtiming $PREFIX/


echo "\n\n\n### install vosk in a venv"
apt install python3-venv
python3 -m venv $VOSK_VENV
$VOSK_VENV/bin/pip install vosk


echo "\n\n\n### install pandoc"
apt install pandoc


echo "\n\n\n### install coolreader"
echo "optional alternative to pandoc, for better integration with cr3"
echo "installation takes awhile"
echo -n "proceed? [y/N]"
read install_cr
if [ "$install_cr" != "y" ]; then
  exit 0;
fi
apt install build-essential git cmake curl pkg-config zlib1g-dev libpng-dev \
  libjpeg-dev libfreetype6-dev libfontconfig1-dev libharfbuzz-dev libfribidi-dev \
  libunibreak-dev libzstd-dev libutf8proc-dev \
;
rm -r /tmp/coolreader
git clone $COOLREADER_GIT_URL /tmp/coolreader \
 && cd /tmp/coolreader/ \
 && apt install qtbase5-dev qttools5-dev \
 && mkdir qtbuild \
 && cd qtbuild \
 && cmake \
    -D GUI=QT5 \
    -D CMAKE_BUILD_TYPE=Release \
    -D MAX_IMAGE_SCALE_MUL=2 \
    -D DOC_DATA_COMPRESSION_LEVEL=3 \
    -D DOC_BUFFER_SIZE=0x1400000 \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    .. \
  && make \
  && make install \
;
