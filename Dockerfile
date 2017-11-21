FROM ubuntu:16.04

RUN apt update && apt install -y build-essential wget curl gawk flex bison bzip2 liblzma5 texinfo
ADD . /build

ENV LFS=/mnt/lfs
ENV TOOLS=$LFS/.dapp/deps/base/0.2.0

RUN mkdir -pv $TOOLS && mkdir -pv $LFS/sources && chmod -v a+wt $LFS/sources
RUN wget --input-file=/build/wget-list --continue --directory-prefix=$LFS/sources && \
pushd $LFS/sources && \
md5sum -c /build/md5sums && \
popd

RUN echo "GO: $LFS"
#RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.29.tar.gz
