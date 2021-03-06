Release Process
====================

* * *

###update (commit) version in sources


	umbrella-ltc-qt.pro
	contrib/verifysfbinaries/verify.sh
	doc/README*
	share/setup.nsi
	src/clientversion.h (change CLIENT_VERSION_IS_RELEASE to true)

###tag version in git

	git tag -a v0.8.0

###write release notes. git shortlog helps a lot, for example:

	git shortlog --no-merges v0.7.2..v0.8.0

* * *

##perform gitian builds

###Ubuntu 12.04.3 LTS amd64 prerequisities

        sudo apt-get install git apache2 apt-cacher-ng python-vm-builder ruby qemu-utils
	sudo apt-get install debootstrap lxc # for LXC mode
	git clone https://github.com/devrandom/gitian-builder.git

	cd gitian-builder
	bin/make-base-vm --lxc --arch amd64 --suite precise

	# LXC network (may be need run each time or add the device to /etc/networks/interface)
	sudo brctl addbr br0
	sudo ifconfig br0 10.0.2.2/24 up

###The build itself

 From a directory containing the Compcoin source, gitian-builder and gitian.sigs
  
	export SIGNER=(your gitian key, ie bluematt, sipa, etc)
	export VERSION=0.0.0
	export USE_LXC=1
	cd ./gitian-builder

 Fetch and build inputs: (first time, or when dependency versions change)

 for multicore CPUs add the -jN to gbuild

	mkdir -p inputs; cd inputs/

	#Linux
	wget 'http://ftp.gnu.org/gnu/gcc/gcc-4.8.1/gcc-4.8.1.tar.bz2'	
	wget 'http://isl.gforge.inria.fr/isl-0.11.1.tar.gz'
	wget 'http://www.bastoul.net/cloog/pages/download/cloog-0.18.1.tar.gz'
	wget 'http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.6.tar.gz' -O miniupnpc-1.6.tar.gz
	wget 'http://fukuchi.org/works/qrencode/qrencode-3.2.0.tar.bz2'
	wget 'http://downloads.sourceforge.net/project/boost/boost/1.55.0/boost_1_55_0.tar.bz2'
	cd ..
	./bin/gbuild ../umbrella-ltc/contrib/gitian-descriptors/gcc-4.8.1.yml
 	mv build/out/gcc-4.8.1-linux64.zip inputs/
	./bin/gbuild ../umbrella-ltc/contrib/gitian-descriptors/boost-linux64-gcc-4.8.1.yml
	mv build/out/boost-linux64-1.55.0.zip inputs/

	#Windows
	wget 'http://download.qt-project.org/archive/qt/4.8/4.8.3/qt-everywhere-opensource-src-4.8.3.tar.gz'
	wget 'http://www.openssl.org/source/openssl-1.0.1g.tar.gz'
	wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	wget 'http://downloads.sourceforge.net/project/libpng/zlib/1.2.6/zlib-1.2.6.tar.gz'
	wget 'http://downloads.sourceforge.net/project/libpng/libpng15/older-releases/1.5.9/libpng-1.5.9.tar.gz'
	wget 'https://svn.boost.org/trac/boost/raw-attachment/ticket/7262/boost-mingw.patch'
	#wget 'http://ftp.gnu.org/gnu/binutils/binutils-2.23.1.tar.bz2'
	wget 'http://netcologne.dl.sourceforge.net/project/mingw-w64/mingw-w64/mingw-w64-release/mingw-w64-v3.1.0.tar.bz2'
	mv boost-mingw.patch boost-mingw-gas-cross-compile-2013-03-03.patch
	cd ..
	./bin/gbuild ../umbrella-ltc/contrib/gitian-descriptors/mingw-w64-gcc-4.8.2.yml
	mv build/out/mingw-w64-gcc-4.8.2-gitian-r1.zip inputs/
	./bin/gbuild ../umbrella-ltc/contrib/gitian-descriptors/boost-win32.yml
	mv build/out/boost-win32-1.55.0-gitian-r6.zip inputs/
	./bin/gbuild ../umbrella-ltc/contrib/gitian-descriptors/deps-win32.yml
	mv build/out/bitcoin-deps-win32-gitian-r9.zip inputs/
	./bin/gbuild ../umbrella-ltc/contrib/gitian-descriptors/qt-win32.yml
	mv build/out/qt-win32-4.8.3-gitian-r4.zip inputs/

 Build umbrella-ltcd and umbrella-ltc-qt on Linux64
  
	./bin/gbuild --commit umbrella-ltc=v${VERSION} ../umbrella-ltc/contrib/gitian-descriptors/gitian-linux64-gcc-4.8.1.yml
	./bin/gsign --signer $SIGNER --release ${VERSION} --destination ../gitian.sigs/ ../umbrella-ltc/contrib/gitian-descriptors/gitian-linux64-gcc-4.8.1.yml
	pushd build/out
	zip -r umbrella-ltc-${VERSION}-linux-gitian.zip *
	mv umbrella-ltc-${VERSION}-linux-gitian.zip ../../
	popd

 Build umbrella-ltcd and umbrella-ltc-qt on Win32
      
	./bin/gbuild --commit umbrella-ltc=v${VERSION} ../umbrella-ltc/contrib/gitian-descriptors/gitian-win32-gcc-4.8.1.yml
	./bin/gsign --signer $SIGNER --release ${VERSION}-win32 --destination ../gitian.sigs/ ../umbrella-ltc/contrib/gitian-descriptors/gitian-win32-gcc-4.8.1.yml
	pushd build/out
	zip -r umbrella-ltc-${VERSION}-win32-gitian.zip *
	mv umbrella-ltc-${VERSION}-win32-gitian.zip ../../
	popd


###Next steps:

* Code-sign Windows -setup.exe (in a Windows virtual machine) and
  OSX Bitcoin-Qt.app (Note: only Gavin has the code-signing keys currently)

* upload builds to SourceForge

* create SHA256SUMS for builds, and PGP-sign it

* update umbrella-ltc.org version
  make sure all OS download links go to the right versions

* update forum version

* update wiki download links

* update wiki changelog: [https://en.umbrella-ltc.it/wiki/Changelog](https://en.bitcoin.it/wiki/Changelog)

Commit your signature to gitian.sigs:

	pushd gitian.sigs
	git add ${VERSION}/${SIGNER}
	git add ${VERSION}-win32/${SIGNER}
	git commit -a
	git push  # Assuming you can push to the gitian.sigs tree
	popd

-------------------------------------------------------------------------

### After 3 or more people have gitian-built, repackage gitian-signed zips:

From a directory containing umbrella-ltc source, gitian.sigs and gitian zips

	export VERSION=0.5.1
	mkdir umbrella-ltc-${VERSION}-linux-gitian
	pushd umbrella-ltc-${VERSION}-linux-gitian
	unzip ../umbrella-ltc-${VERSION}-linux-gitian.zip
	mkdir gitian
	cp ../umbrella-ltc/contrib/gitian-downloader/*.pgp ./gitian/
	for signer in $(ls ../gitian.sigs/${VERSION}/); do
	 cp ../gitian.sigs/${VERSION}/${signer}/umbrella-ltc-build.assert ./gitian/${signer}-build.assert
	 cp ../gitian.sigs/${VERSION}/${signer}/umbrella-ltc-build.assert.sig ./gitian/${signer}-build.assert.sig
	done
	zip -r umbrella-ltc-${VERSION}-linux-gitian.zip *
	cp umbrella-ltc-${VERSION}-linux-gitian.zip ../
	popd
	mkdir umbrella-ltc-${VERSION}-win32-gitian
	pushd umbrella-ltc-${VERSION}-win32-gitian
	unzip ../umbrella-ltc-${VERSION}-win32-gitian.zip
	mkdir gitian
	cp ../umbrella-ltc/contrib/gitian-downloader/*.pgp ./gitian/
	for signer in $(ls ../gitian.sigs/${VERSION}-win32/); do
	 cp ../gitian.sigs/${VERSION}-win32/${signer}/umbrella-ltc-build.assert ./gitian/${signer}-build.assert
	 cp ../gitian.sigs/${VERSION}-win32/${signer}/umbrella-ltc-build.assert.sig ./gitian/${signer}-build.assert.sig
	done
	zip -r umbrella-ltc-${VERSION}-win32-gitian.zip *
	cp umbrella-ltc-${VERSION}-win32-gitian.zip ../
	popd

- Upload gitian zips to SourceForge
- Celebrate 
