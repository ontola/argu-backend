FROM ruby:3.0.2-alpine3.13

# Install mozjpeg & libvips
ARG LIBVIPS_VERSION_MAJOR_MINOR=8.13
ARG LIBVIPS_VERSION_PATCH=0
ARG MOZJPEG_VERSION="v3.3.1"
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.11/community" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --update \
    zlib libxml2 libxslt glib libexif lcms2 fftw ca-certificates \
    giflib libpng libwebp orc tiff poppler-glib librsvg
RUN  apk add --no-cache --virtual .build-dependencies autoconf automake build-base cmake \
    git libtool nasm zlib-dev libxml2-dev libxslt-dev glib-dev \
    libexif-dev lcms2-dev fftw-dev giflib-dev libpng-dev libwebp-dev orc-dev tiff-dev \
    poppler-dev librsvg-dev wget

RUN echo 'Install mozjpeg'
RUN cd /tmp &&\
    git clone -b ${MOZJPEG_VERSION} --single-branch --depth 1 https://github.com/mozilla/mozjpeg.git &&\
    cd /tmp/mozjpeg &&\
    autoreconf -fiv && ./configure --prefix=/usr && make install

RUN echo 'Install libvips'
RUN wget -O- https://github.com/libvips/libvips/releases/download/v${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH}/vips-${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH}.tar.gz | tar xzC /tmp
RUN cd /tmp/vips-${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH}
RUN ./configure --prefix=/usr \
                --without-gsf \
                --enable-debug=no \
                --disable-dependency-tracking \
                --disable-static \
                --enable-silent-rules
RUN make -s install-strip
RUN cd $OLDPWD

RUN echo 'Cleanup'
RUN rm -rf /tmp/vips-${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH}
RUN rm -rf /tmp/mozjpeg
RUN apk del --purge .build-dependencies
RUN rm -rf /var/cache/apk/*

RUN apk --update --no-cache add curl openssh-client postgresql-dev libffi-dev libxml2-dev libxslt-dev libwebp-dev

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle config build.nokogiri --use-system-libraries

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/

RUN apk --update --no-cache add git build-base pkgconfig\
    && RAILS_ENV=production bundle install --deployment --frozen --clean --without development test --path vendor/bundle\
    && apk del git pkgconfig build-base

COPY . /usr/src/app

EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
