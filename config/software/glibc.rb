name "glibc"
default_version "2.26"

license 'GPL-2'
license_file 'COPYING'

version("2.26") { source md5: "ae2a3cddba005b34792dabe8c103e866" }

source url: "https://ftp.gnu.org/gnu/glibc/glibc-#{version}.tar.gz"

relative_path "glibc-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  command "mkdir build"

  command(
    "../configure --prefix=#{install_dir}/embedded" +
    " --disable-werror --enable-kernel=3.2 --enable-stack-protector=strong" +
    " libc_cv_slibdir=#{install_dir}/embedded/lib",
    env: env,
    cwd: "build",
  )

  command "make -j #{workers}", env: env
  command 'make install', env: env
end
