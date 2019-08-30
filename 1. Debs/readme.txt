[Compile Steps]

git clone -b master_darwin-embedded https://github.com/fuzzard/xbmc.git kodi
	cd kodi/tools/depends
	./bootstrap
	./configure --host=arm-apple-darwin --with-platform=tvos
	make -j$(getconf _NPROCESSORS_ONLN)

cd $HOME/kodi
	make -C tools/depends/target/binary-addons

cd 
mkdir $HOME/kodi-build
cd kodi-build

/Users/Shared/xbmc-depends/x86_64-darwin18.7.0-native/bin/cmake -G Xcode -DCMAKE_TOOLCHAIN_FILE=/Users/Shared/xbmc-depends/appletvos12.4_arm64-target-debug/share/Toolchain.cmake /kodi
/Users/Shared/xbmc-depends/x86_64-darwin18.7.0-native/bin/cmake --build . --target "deb" --config "Debug"