#!/bin/sh

set -e
set -u

jflag=
jval=2
rebuild=0
download_only=0
uname -mpi | grep -qE 'x86|i386|i686' && is_x86=1 || is_x86=0

WORKDIR=$PWD

# PKG_CONFIG_PATH=$WORKDIR/target/lib/pkgconfig

HOST=aarch64-linux-gnu

while getopts 'j:Bd' OPTION
do
  case $OPTION in
  j)
      jflag=1
      jval="$OPTARG"
      ;;
  B)
      rebuild=1
      ;;
  d)
      download_only=1
      ;;
  ?)
      printf "Usage: %s: [-j concurrency_level] (hint: your cores + 20%%) [-B] [-d]\n" $(basename $0) >&2
      exit 2
      ;;
  esac
done
shift $(($OPTIND - 1))

if [ "$jflag" ]
then
  if [ "$jval" ]
  then
    printf "Option -j specified (%d)\n" $jval
  fi
fi

[ "$rebuild" -eq 1 ] && echo "Reconfiguring existing packages..."
[ $is_x86 -ne 1 ] && echo "Not using yasm or nasm on non-x86 platform..."

cd `dirname $0`
ENV_ROOT=`pwd`
. ./env.source

# check operating system
OS=`uname`
platform="unknown"

case $OS in
  'Darwin')
    platform='darwin'
    ;;
  'Linux')
    platform='linux'
    ;;
esac

#if you want a rebuild
#rm -rf "$BUILD_DIR" "$TARGET_DIR"
mkdir -p "$BUILD_DIR" "$TARGET_DIR" "$DOWNLOAD_DIR" "$BIN_DIR"

#download and extract package
download(){
  filename="$1"
  if [ ! -z "$2" ];then
    filename="$2"
  fi
  ../download.pl "$DOWNLOAD_DIR" "$1" "$filename" "$3" "$4"
  #disable uncompress
  REPLACE="$rebuild" CACHE_DIR="$DOWNLOAD_DIR" ../fetchurl "http://cache/$filename"
}

echo "#### FFmpeg static build ####"

#this is our working directory
cd $BUILD_DIR

[ $is_x86 -eq 1 ] && download \
  "yasm-1.3.0.tar.gz" \
  "" \
  "fc9e586751ff789b34b1f21d572d96af" \
  "http://www.tortall.net/projects/yasm/releases/"

[ $is_x86 -eq 1 ] && download \
  "nasm-2.13.01.tar.gz" \
  "" \
  "16050aa29bc0358989ef751d12b04ed2" \
  "http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/"

download \
  "OpenSSL_1_0_2o.tar.gz" \
  "" \
  "5b5c050f83feaa0c784070637fac3af4" \
  "https://github.com/openssl/openssl/archive/"

download \
  "v1.2.11.tar.gz" \
  "zlib-1.2.11.tar.gz" \
  "0095d2d2d1f3442ce1318336637b695f" \
  "https://github.com/madler/zlib/archive/"

download \
  "last_x264.tar.bz2" \
  "" \
  "nil" \
  "http://download.videolan.org/pub/videolan/x264/snapshots/"

download \
  "x265_2.7.tar.gz" \
  "" \
  "b0d7d20da2a418fa4f53a559946ea079" \
  "https://bitbucket.org/multicoreware/x265/downloads/"

download \
  "v0.1.6.tar.gz" \
  "fdk-aac.tar.gz" \
  "223d5f579d29fb0d019a775da4e0e061" \
  "https://github.com/mstorsjo/fdk-aac/archive"

# libass dependency
download \
  "harfbuzz-2.4.0.tar.bz2" \
  "" \
  "49f111f9b52ae3d9b31c1a3631a320bd" \
  "https://www.freedesktop.org/software/harfbuzz/release/"

download \
  "fribidi-1.0.2.tar.bz2" \
  "" \
  "bd2eb2f3a01ba11a541153f505005a7b" \
  "https://github.com/fribidi/fribidi/releases/download/v1.0.2/"

download \
  "0.14.0.tar.gz" \
  "libass-0.14.0.tar.gz" \
  "nil" \
  "https://github.com/libass/libass/archive/"

download \
  "lame-3.100.tar.gz" \
  "" \
  "nil" \
  "http://downloads.sourceforge.net/project/lame/lame/3.100"

download \
  "opus-1.1.2.tar.gz" \
  "" \
  "1f08a661bc72930187893a07f3741a91" \
  "https://github.com/xiph/opus/releases/download/v1.1.2"

download \
  "v1.8.0.tar.gz" \
  "vpx-1.8.0.tar.gz" \
  "nil" \
  "https://github.com/webmproject/libvpx/archive"

download \
  "rtmpdump-2.3.tgz" \
  "" \
  "eb961f31cd55f0acf5aad1a7b900ef59" \
  "https://rtmpdump.mplayerhq.hu/download/"

download \
  "soxr-0.1.2-Source.tar.xz" \
  "" \
  "0866fc4320e26f47152798ac000de1c0" \
  "https://sourceforge.net/projects/soxr/files/"

download \
  "v1.1.0.tar.gz" \
  "vid.stab-1.1.0.tar.gz" \
  "nil" \
  "https://github.com/georgmartius/vid.stab/archive/"

download \
  "release-2.7.4.tar.gz" \
  "zimg-release-2.7.4.tar.gz" \
  "1757dcc11590ef3b5a56c701fd286345" \
  "https://github.com/sekrit-twc/zimg/archive/"

download \
  "v2.1.2.tar.gz" \
  "openjpeg-2.1.2.tar.gz" \
  "40a7bfdcc66280b3c1402a0eb1a27624" \
  "https://github.com/uclouvain/openjpeg/archive/"

download \
  "v0.6.1.tar.gz" \
  "libwebp-0.6.1.tar.gz" \
  "1c3099cd2656d0d80d3550ee29fc0f28" \
  "https://github.com/webmproject/libwebp/archive/"

download \
  "v1.3.6.tar.gz" \
  "vorbis-1.3.6.tar.gz" \
  "03e967efb961f65a313459c5d0f4cbfb" \
  "https://github.com/xiph/vorbis/archive/"

download \
  "v1.3.3.tar.gz" \
  "ogg-1.3.3.tar.gz" \
  "b8da1fe5ed84964834d40855ba7b93c2" \
  "https://github.com/xiph/ogg/archive/"

download \
  "Speex-1.2.0.tar.gz" \
  "Speex-1.2.0.tar.gz" \
  "4bec86331abef56129f9d1c994823f03" \
  "https://github.com/xiph/speex/archive/"

download \
  "freetype-2.10.0.tar.gz" \
  "freetype-2.10.0.tar.gz" \
  "58d56c9ad775326d6c9c5417c462a527" \
  "https://download.savannah.gnu.org/releases/freetype/"

download \
  "fontconfig-2.13.1.tar.gz" \
  "fontconfig-2.13.1.tar.gz" \
  "690c6cb840a92fa8908cdf462d19ec66" \
  "https://download.savannah.gnu.org/releases/freetype/"

download \
  "frei0r-plugins-1.6.1.tar.gz" \
  "frei0r-plugins-1.6.1.tar.gz" \
  "nil" \
  "https://files.dyne.org/frei0r/releases/"

download \
  "libtheora-1.1.1.tar.bz2" \
  "libtheora-1.1.1.tar.bz2" \
  "nil" \
  "http://downloads.xiph.org/releases/theora/"

download \
  "n3.4.6.tar.gz" \
  "FFmpeg-n3.4.6.tar.gz" \
  "nil" \
  "https://www.freedesktop.org/software/fontconfig/"

[ $download_only -eq 1 ] && exit 0

TARGET_DIR_SED=$(echo $TARGET_DIR | awk '{gsub(/\//, "\\/"); print}')

if [ $is_x86 -eq 1 ]; then
    echo "*** Building yasm ***"
    cd $BUILD_DIR/yasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR --host=$HOST
    make -j $jval
    make install
fi

if [ $is_x86 -eq 1 ]; then
    echo "*** Building nasm ***"
    cd $BUILD_DIR/nasm*
    [ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
    [ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --bindir=$BIN_DIR --host=$HOST
    make -j $jval
    make install
fi

echo "*** Building OpenSSL ***"
cd $BUILD_DIR/openssl*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "darwin" ]; then
  PATH="$BIN_DIR:$PATH" ./Configure darwin64-x86_64-cc --prefix=$TARGET_DIR
elif [ "$platform" = "linux" ]; then
  # PATH="$BIN_DIR:$PATH" ./config --prefix=$TARGET_DIR -host=$HOST --cross-compile-prefix=$HOST
  PATH="$BIN_DIR:$PATH" ./Configure linux-aarch64 --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building zlib ***"
cd $BUILD_DIR/zlib*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" CC=$HOST-gcc CXX=$HOST-g++ ./configure --prefix=$TARGET_DIR
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR
fi
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building x264 ***"
cd $BUILD_DIR/x264*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --enable-static --enable-pic --host=$HOST
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building x265 ***"
cd $BUILD_DIR/x265*
cd build/linux
[ $rebuild -eq 1 ] && find . -mindepth 1 ! -name 'make-Makefiles.bash' -and ! -name 'multilib.sh' -exec rm -r {} +
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DENABLE_SHARED:BOOL=OFF -DSTATIC_LINK_CRT:BOOL=ON -DENABLE_CLI:BOOL=OFF \
	-DCMAKE_TOOLCHAIN_FILE=$WORKDIR/cmake-tc/toolchain-arm64.cmake ../../source
sed -i 's/-lgcc_s/-lgcc_eh/g' x265.pc
make -j $jval
make install

echo "*** Building fdk-aac ***"
cd $BUILD_DIR/fdk-aac*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
autoreconf -fiv
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared --host=$HOST
make -j $jval
make install

echo "*** Building freetype 1st pass ***"
cd $BUILD_DIR/freetype-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --enable-static --disable-docs --host=$HOST --without-harfbuzz
make -j $jval
make install

echo "*** Building harfbuzz ***"
cd $BUILD_DIR/harfbuzz-*
mkdir -p build/ && cd build/ 
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
# ./configure --prefix=$TARGET_DIR --disable-shared --enable-static --host=$HOST
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DENABLE_SHARED:BOOL=OFF -DSTATIC_LINK_CRT:BOOL=ON -DENABLE_CLI:BOOL=OFF \
       -DCMAKE_TOOLCHAIN_FILE=$WORKDIR/cmake-tc/toolchain-arm64.cmake ../
make -j $jval
make install

echo "*** Building freetype 2nd pass ***"
cd $BUILD_DIR/freetype-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --enable-static --disable-docs --host=$HOST
make -j $jval
make install

echo "*** Building fribidi ***"
cd $BUILD_DIR/fribidi-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --enable-static --disable-docs --host=$HOST
make -j $jval
make install

echo "*** Building libass ***"
cd $BUILD_DIR/libass-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared --host=$HOST --disable-require-system-font-provider --disable-harfbuzz
make -j $jval
make install

echo "*** Building mp3lame ***"
cd $BUILD_DIR/lame*
# The lame build script does not recognize aarch64, so need to set it manually
uname -a | grep -q 'aarch64' && lame_build_target="--build=arm-linux" || lame_build_target=''
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --enable-nasm --disable-shared $lame_build_target --host=$HOST --target=$HOST
make
make install

echo "*** Building opus ***"
cd $BUILD_DIR/opus*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && ./configure --prefix=$TARGET_DIR --disable-shared --target=$HOST --host=$HOST
make
make install

echo "*** Building libvpx ***"
cd $BUILD_DIR/libvpx*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
[ ! -f config.status ] && PATH="$BIN_DIR:$PATH" ./configure --prefix=$TARGET_DIR --disable-examples --disable-unit-tests --enable-pic --target=$HOST-gcc
PATH="$BIN_DIR:$PATH" make -j $jval
make install

echo "*** Building librtmp ***"
cd $BUILD_DIR/rtmpdump-*
cd librtmp
[ $rebuild -eq 1 ] && make distclean || true

# there's no configure, we have to edit Makefile directly
if [ "$platform" = "linux" ]; then
  sed -i "/INC=.*/d" ./Makefile # Remove INC if present from previous run.
  sed -i "s/prefix=.*/prefix=${TARGET_DIR_SED}\nINC=-I\$(prefix)\/include/" ./Makefile
  sed -i "s/SHARED=.*/SHARED=no/" ./Makefile
elif [ "$platform" = "darwin" ]; then
  sed -i "" "s/prefix=.*/prefix=${TARGET_DIR_SED}/" ./Makefile
fi
make CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar install_base

echo "*** Building libsoxr ***"
cd $BUILD_DIR/soxr-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off -DWITH_OPENMP:bool=off -DBUILD_TESTS:bool=off \
	-DCMAKE_TOOLCHAIN_FILE=$WORKDIR/cmake-tc/toolchain-arm64.cmake
make -j $jval
make install

echo "*** Building libvidstab ***"
cd $BUILD_DIR/vid.stab-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
if [ "$platform" = "linux" ]; then
  sed -i "s/vidstab SHARED/vidstab STATIC/" ./CMakeLists.txt
elif [ "$platform" = "darwin" ]; then
  sed -i "" "s/vidstab SHARED/vidstab STATIC/" ./CMakeLists.txt
fi
# PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DCMAKE_TOOLCHAIN_FILE=$WORKDIR/cmake-tc/toolchain-arm64.cmake
PATH="$BIN_DIR:$PATH" cmake -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DCMAKE_TOOLCHAIN_FILE=$WORKDIR/cmake-tc/toolchain-arm64.cmake
make -j $jval
make install

echo "*** Building openjpeg ***"
cd $BUILD_DIR/openjpeg-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
PATH="$BIN_DIR:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$TARGET_DIR" -DBUILD_SHARED_LIBS:bool=off -DCMAKE_TOOLCHAIN_FILE=$WORKDIR/cmake-tc/toolchain-arm64.cmake
make -j $jval
make install

echo "*** Building zimg ***"
cd $BUILD_DIR/zimg-release-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --enable-static  --prefix=$TARGET_DIR --disable-shared --host=$HOST
make -j $jval
make install

echo "*** Building libwebp ***"
cd $BUILD_DIR/libwebp*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared --host=$HOST
make -j $jval
make install

echo "*** Building libvorbis ***"
cd $BUILD_DIR/vorbis*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared --host=$HOST
make -j $jval
make install

echo "*** Building libogg ***"
cd $BUILD_DIR/ogg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared --host=$HOST
make -j $jval
make install

echo "*** Building libspeex ***"
cd $BUILD_DIR/speex*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./autogen.sh
./configure --prefix=$TARGET_DIR --disable-shared --host=$HOST
make -j $jval
make install

echo "*** Building fontconfig ***"
cd $BUILD_DIR/fontconfig-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --disable-shared --host=$HOST --with-arch=amr64
make -j $jval
make install

echo "*** Building frei0r ***"
cd $BUILD_DIR/frei0r-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --host=$HOST
make -j $jval
make install

echo "*** Building theora ***"
cd $BUILD_DIR/libtheora-*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true
./configure --prefix=$TARGET_DIR --host=$HOST
make -j $jval
make install

exit 0

# FFMpeg
echo "*** Building FFmpeg ***"
cd $BUILD_DIR/FFmpeg*
[ $rebuild -eq 1 -a -f Makefile ] && make distclean || true

if [ "$platform" = "linux" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="$TARGET_DIR/lib/pkgconfig" \
  LDFLAGS="-L$TARGET_DIR/lib:$LDFLAGS" ./configure \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-libs="-lpthread -lm -lz" \
    --extra-ldexeflags="-static" \
    --bindir="$BIN_DIR" \
    --enable-cross-compile \
    --cross-prefix=$HOST- \
    --arch=arm64 \
    --target-os=linux \
    --enable-pic \
    --enable-ffplay \
    --enable-ffserver \
    --enable-gpl \
    --enable-version3 \
    --enable-libass \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libmp3lame \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx265 \
    --enable-libzimg \
    --enable-nonfree \
    --enable-openssl
elif [ "$platform" = "darwin" ]; then
  [ ! -f config.status ] && PATH="$BIN_DIR:$PATH" \
  PKG_CONFIG_PATH="${TARGET_DIR}/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/Cellar/openssl/1.0.2o_1/lib/pkgconfig" ./configure \
    --cc=/usr/bin/clang \
    --prefix="$TARGET_DIR" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I$TARGET_DIR/include" \
    --extra-ldflags="-L$TARGET_DIR/lib" \
    --extra-ldexeflags="-Bstatic" \
    --bindir="$BIN_DIR" \
    --enable-pic \
    --enable-ffplay \
    --enable-fontconfig \
    --enable-frei0r \
    --enable-gpl \
    --enable-version3 \
    --enable-libass \
    --enable-libfribidi \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopenjpeg \
    --enable-libopus \
    --enable-librtmp \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libvidstab \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libzimg \
    --enable-nonfree \
    --enable-openssl
fi

PATH="$BIN_DIR:$PATH" make -j $jval
make install
make distclean
hash -r
