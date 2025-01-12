#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = x265 version

# load functions
. $1/functions.sh
 set -x

SOFTWARE=SDL

make_directories() {

# start in working directory
  cd "$2"
  checkStatus $? "change directory failed"
  mkdir "${SOFTWARE}"
  checkStatus $? "create directory failed"
  cd "${SOFTWARE}"
  checkStatus $? "change directory failed"
  mkdir "build-${SOFTWARE}"
  checkStatus $? "create directory failed"

}


download_code() {
  cd "$2/$SOFTWARE"
  checkStatus $? "change directory failed"

  # download source
  git clone https://github.com/libsdl-org/SDL.git 
  checkStatus $? "download of $SOFTWARE failed"

}

configure_build () {

   
  cd "$2/$SOFTWARE/build-$SOFTWARE"
  checkStatus $? "change directory failed"

  
 # prepare build

  cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DBUILD_SHARED_LIBS=NO ../SDL
  checkStatus $? "configuration of ${SOFTWARE} failed"


}

make_clean() {

  cd "$2/${SOFTWARE}/build-${SOFTWARE}"
  checkStatus $? "change directory failed"

  make clean
  checkStatus $? "make clean of ${SOFTWARE} failed"


}

make_compile () {

  cd "$2/${SOFTWARE}/build-${SOFTWARE}"
  checkStatus $? "change directory failed"
  # build
  cmake --build .
  checkStatus $? "build of $SOFTWARE failed"


#  ln -s libSDL2-2.0.dylib libSDL2.dylib 

  # install
  cmake --install .  
  checkStatus $? "installation of ${SOFTWARE} failed"

}


build_main () {

  if [[ -d "$2/${SOFTWARE}" && "${ACTION}" == "skip" ]]
  then
      return 0
  elif [[ -d "$2/${SOFTWARE}" && -z "${ACTION}" ]]
  then
      echo "${SOFTWARE} build directory already exists but no action set. Exiting script"
      exit 0
  fi


  if [[ ! -d "$2/${SOFTWARE}" ]]
  then
    make_directories $@
    download_code $@
    configure_build $@
  fi

  make_clean $@
  make_compile $@

}


build_main $@
