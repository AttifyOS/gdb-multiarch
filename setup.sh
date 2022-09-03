#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${APM_TMP_DIR}" ]]; then
    echo "APM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_INSTALL_DIR}" ]]; then
    echo "APM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${APM_PKG_BIN_DIR}" ]]; then
    echo "APM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/AttifyOS/gdb-multiarch/releases/download/v12.1/gdb-12.1-build.tar.gz -O $APM_TMP_DIR/gdb-12.1-build.tar.gz
  tar xf $APM_TMP_DIR/gdb-12.1-build.tar.gz -C $APM_PKG_INSTALL_DIR
  rm $APM_TMP_DIR/gdb-12.1-build.tar.gz
  echo "source $APM_PKG_INSTALL_DIR/.gdbinit-gef.py" > $APM_PKG_INSTALL_DIR/.gdbinit

  echo "#!/bin/sh" > $APM_PKG_BIN_DIR/gdb-multiarch
  echo "$APM_PKG_INSTALL_DIR/bin/gdb -x $APM_PKG_INSTALL_DIR/.gdbinit \"$@\"" >> $APM_PKG_BIN_DIR/gdb-multiarch
  chmod +x $APM_PKG_BIN_DIR/gdb-multiarch
  
  echo "This package adds the command gdb-multiarch"
}

uninstall() {
  rm $APM_PKG_INSTALL_DIR/.gdbinit*
  rm -rf $APM_PKG_INSTALL_DIR/*
  rm $APM_PKG_BIN_DIR/gdb-multiarch
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1