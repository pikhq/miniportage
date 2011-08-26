#!/bin/sh -e

dummy(){
    true
}

generic_src(){
    wget $src_url/$file$ext
}

gnu_src(){
    src_url=http://ftp.gnu.org/gnu/$name/
    generic_src
}

tar_unpack(){
    tar -xf $file$ext
}

unpack(){
    tar_unpack
}

patches_preconfig(){
    for i in ../$name*.patch;do
	if [ -e $i ];then
	    patch -p1 <$i
	fi
    done
}

preconfig(){
    patches_preconfig
}

kconfig_config(){
    make allnoconfig KCONFIG_ALLCONFIG=../$name.config $make_flags
}

autoconf_config(){
    ./configure --prefix=$prefix $configure_flags
}

config(){
    autoconf_config
}

make_build(){
    make $make_flags
}

build(){
    make_build
}

make_install(){
    make install prefix=$destdir $make_install_flags
}

install(){
    make_install
}

postinstall(){
    true
}


clean(){
    rm -rf $dir
}

predefaults(){
    : ${name:=$(basename $1 .sh)}
}

postdefaults(){
    : ${ext:=.tar.bz2}
    : ${name:=$(basename $1 .sh)}
    : ${file:=$name-$version}
    : ${dir:=$name-$version}

    : ${source:=generic_src}
    : ${unpack:=unpack}
    : ${preconfig:=preconfig}
    : ${config:=config}
    : ${build:=build}
    : ${install:=install}
    : ${postinstall:=postinstall}
    : ${clean:=clean}
}

while getopts bfh opt;do
    case $opt in
	b) stage=build;;
	f) stage=fetch;;
	\?) usage;;
    esac
done
shift `expr $OPTIND - 1`

cwd=$(pwd)
arch=$(uname -m)

predefaults "$@"
. $(dirname $1)/$(basename $1)
postdefaults "$@"

case $stage in
    build)
	test -e $file$ext || $source
	$clean
	$unpack
	cd $dir
	$preconfig
	$config
	$build
	$install
	$postinstall
	cd $cwd
	$clean
	;;
    fetch)
	test -e $file$ext || $source
esac
