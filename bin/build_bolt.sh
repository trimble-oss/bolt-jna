#!/bin/bash

set -e

export ROOT_HOME=$(cd `dirname "$0"` && cd .. && pwd)

export GOROOT=${GOROOT:-}
export GO=${GO:-go}

export BOLT_HOME=$GOPATH/src/github.com/boltdb/bolt

echo "GOROOT: $GOROOT"
echo "GO: $GO"

if [[ "$1" == "clean" ]]; then
  echo --------------------
  echo Clean
  echo --------------------

  rm -rf pkg
fi

echo --------------------
echo Build Bolt
echo --------------------

if [[ "$OSTYPE" == "darwin"* ]]; then
  BOLT_FILE=libbolt.dylib
  BOLT_ARCH=darwin
  OUTPUT_LEVELDB_FILE=

  $GO build -o pkg/protonail.com/bolt-jna/$BOLT_FILE -buildmode=c-shared protonail.com/bolt-jna
elif [[ "$OSTYPE" == "linux"* ]]; then
#  echo Build Mac
#  BOLT_FILE=libbolt.dylib
#  BOLT_ARCH=darwin
#  OUTPUT_LEVELDB_FILE=

#  CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 $GO build -buildmode=c-shared -o pkg/protonail.com/bolt-jna/$BOLT_FILE protonail.com/bolt-jna/lib
#  echo --------------------
#  echo Copy Mac Bolt library
#  echo --------------------

#  mkdir -p $ROOT_HOME/bolt-jna-native/src/main/resources/$BOLT_ARCH/
#  cp $GOPATH/pkg/protonail.com/bolt-jna/$BOLT_FILE $ROOT_HOME/bolt-jna-native/src/main/resources/$BOLT_ARCH/$BOLT_FILE

  echo Build Linux
  BOLT_FILE=libbolt.so
  if [[ $(uname -m) == "x86_64" ]]; then
    BOLT_ARCH=linux-x86-64
  else
    BOLT_ARCH=linux-x86
  fi
  OUTPUT_LEVELDB_FILE=
	GOOS=linux GOARCH=amd64 $GO build -buildmode=c-shared -o pkg/protonail.com/bolt-jna/$BOLT_FILE -buildmode=c-shared protonail.com/bolt-jna/lib

  echo --------------------
  echo Copy Linux Bolt library
  echo --------------------

  mkdir -p $ROOT_HOME/bolt-jna-native/src/main/resources/$BOLT_ARCH/
  cp pkg/protonail.com/bolt-jna/$BOLT_FILE $ROOT_HOME/bolt-jna-native/src/main/resources/$BOLT_ARCH/$BOLT_FILE

  echo Build Windows
  BOLT_FILE=bolt.dll
  BOLT_ARCH=win32-x86-64
  OUTPUT_LEVELDB_FILE=
  CGO_ENABLED=1 GOOS=windows GOARCH=amd64 CC=x86_64-w64-mingw32-gcc $GO build -a -ldflags '-w' -o pkg/protonail.com/bolt-jna/$BOLT_FILE -buildmode=c-shared protonail.com/bolt-jna/lib

  echo --------------------
  echo Copy Windows Bolt library
  echo --------------------

  mkdir -p $ROOT_HOME/bolt-jna-native/src/main/resources/$BOLT_ARCH/
  cp pkg/protonail.com/bolt-jna/$BOLT_FILE $ROOT_HOME/bolt-jna-native/src/main/resources/$BOLT_ARCH/$BOLT_FILE

  exit 0

elif [[ "$OSTYPE" == "msys" ]]; then
  BOLT_FILE=bolt.dll
  if [[ "$MSYSTEM" == "MINGW64" ]]; then
    BOLT_ARCH=win32-x86-64
  else
    BOLT_ARCH=win32-x86
  fi
  OUTPUT_LEVELDB_FILE=bolt.dll

  PKG_DIR=$GOPATH/pkg/protonail.com/bolt-jna
  SRC_DIR=$GOPATH/src/protonail.com/bolt-jna

  $GO build -o $PKG_DIR/bolt-jna.a -buildmode=c-archive protonail.com/bolt-jna
  gcc -shared -pthread -static-libgcc -o $PKG_DIR/$BOLT_FILE $ROOT_HOME/patches/WinDLL.c -I$PKG_DIR -I$SRC_DIR $PKG_DIR/bolt-jna.a -lWinMM -lntdll -lWS2_32
fi


echo --------------------
echo Copy Bolt library
echo --------------------

mkdir -p $ROOT_HOME/bolt-jna-native/src/main/resources/$BOLT_ARCH/
cp $GOPATH/pkg/protonail.com/bolt-jna/$BOLT_FILE $ROOT_HOME/bolt-jna-native/src/main/resources/$BOLT_ARCH/$BOLT_FILE
