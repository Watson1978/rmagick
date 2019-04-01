set -euox pipefail

sudo apt-get update

# remove all existing imagemagick related packages
sudo apt-get autoremove -y imagemagick* libmagick* --purge

# install build tools, ImageMagick delegates
sudo apt-get install -y build-essential libx11-dev libxext-dev zlib1g-dev \
  liblcms2-dev libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev \
  libtiff5-dev libwebp-dev vim ghostscript ccache

if [ ! -d /usr/include/freetype ]; then
  # If `/usr/include/freetype` is not existed, ImageMagick 6.7 configuration fails about Freetype.
  sudo ln -sf /usr/include/freetype2 /usr/include/freetype
fi

dir_options=""
if [ -v CONFIGURE_OPTIONS ]; then
  dir_options=$CONFIGURE_OPTIONS
fi

if [ -v IMAGEMAGICK_VERSION ]; then
  if [ -d build-ImageMagick/ImageMagick-${IMAGEMAGICK_VERSION}-${dir_options} ]; then
    cd build-ImageMagick/ImageMagick-${IMAGEMAGICK_VERSION}-${dir_options}
  else
    mkdir -p build-ImageMagick

    version=(${IMAGEMAGICK_VERSION//./ })
    if (( "${version[0]}${version[1]}" >= 69 )); then
      wget https://github.com/ImageMagick/ImageMagick6/archive/${IMAGEMAGICK_VERSION}.tar.gz
      tar -xf ${IMAGEMAGICK_VERSION}.tar.gz
      mv ImageMagick6-${IMAGEMAGICK_VERSION} build-ImageMagick/ImageMagick-${IMAGEMAGICK_VERSION}-${dir_options}
    else
      wget http://www.imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
      tar -xf ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz
      mv ImageMagick-${IMAGEMAGICK_VERSION} build-ImageMagick/ImageMagick-${IMAGEMAGICK_VERSION}-${dir_options}
    fi

    cd build-ImageMagick/ImageMagick-${IMAGEMAGICK_VERSION}-${dir_options}

    options="--with-magick-plus-plus=no --disable-docs"
    if [ -v CONFIGURE_OPTIONS ]; then
      options="${CONFIGURE_OPTIONS} $options"
    fi

    CC="ccache cc" CXX="ccache c++" ./configure --prefix=/usr $options

    make -j
  fi

  sudo make install -j
  cd ../..
else
  echo "you must specify an ImageMagick version."
  echo "example: 'IMAGEMAGICK_VERSION=6.8.9-10 bash ./before_install_linux.sh'"
  exit 1
fi

sudo ldconfig

gem install bundler

set +ux
