FROM ubuntu:16.04

RUN apt update && apt install -y build-essential wget curl gawk flex bison bzip2 liblzma5 texinfo file

ENV LFS=/mnt/lfs
ENV TOOLS=$LFS/.dapp/deps/base/0.2.0

RUN mkdir -pv $TOOLS && mkdir -pv $LFS/sources && chmod -v a+wt $LFS/sources
ADD ./wget-list $LFS/sources/wget-list
ADD ./md5sums $LFS/sources/md5sums
RUN wget --input-file=$LFS/sources/wget-list --continue --directory-prefix=$LFS/sources
RUN bash -c "pushd $LFS/sources && md5sum -c $LFS/sources/md5sums && popd"

RUN ln -sv $LFS/.dapp /
RUN groupadd lfs && useradd -s /bin/bash -g lfs -m -k /dev/null lfs
RUN echo "exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash" >> /home/lfs/.bash_profile
RUN chown -R lfs:lfs $LFS

RUN echo "set +h" >> /home/lfs/.bashrc && \
echo "umask 022" >> /home/lfs/.bashrc && \
echo "LC_ALL=POSIX" >> /home/lfs/.bashrc && \
echo "LFS_TGT=$(uname -m)-lfs-linux-gnu" >> /home/lfs/.bashrc && \
echo "PATH=/$TOOLS/bin:/bin:/usr/bin" >> /home/lfs/.bashrc && \
echo "MAKEFLAGS='-j 5'" >> /home/lfs/.bashrc && \
echo "export LFS LC_ALL LFS_TGT PATH MAKEFLAGS" >> /home/lfs/.bashrc

ADD ./build /build

RUN /build/version-check.sh

USER lfs

RUN cd $LFS/sources/ && \
mkdir binutils && \
tar xf binutils-*.tar.bz2 -C binutils --strip-components 1 && \
cd binutils && \
mkdir -v build && \
cd build && \
../configure --prefix=/$TOOLS \
--with-sysroot=$LFS \
--with-lib-path=/$TOOLS/lib \
--target=$LFS_TGT \
--disable-nls \
--disable-werror
WORKDIR $LFS/sources/binutils/build
RUN make
RUN mkdir -pv /$TOOLS/lib && ln -sv lib /$TOOLS/lib64 && make install

RUN cd $LFS/sources/ && \
mkdir gcc && \
tar xf gcc-*.tar.xz -C gcc --strip-components 1 && \
mkdir gcc/mpfr && \
tar xf mpfr*.tar.xz -C gcc/mpfr --strip-components 1 && \
mkdir gcc/gmp && \
tar xf gmp*.tar.xz -C gcc/gmp --strip-components 1 && \
mkdir gcc/mpc && \
tar xf mpc*.tar.xz -C gcc/mpc --strip-components 1 && \
