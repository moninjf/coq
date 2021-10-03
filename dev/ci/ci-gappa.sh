#!/usr/bin/env bash

set -e

ci_dir="$(dirname "$0")"
. "${ci_dir}/ci-common.sh"

git_download gappa_tool

( cd "${CI_BUILD_DIR}/gappa_tool"
  if [ ! -x ./configure ]; then
      autoreconf
      touch stamp-config_h.in
      ./configure --prefix="$CI_INSTALL_DIR"
  fi
  ./remake "-j${NJOBS}"
  ./remake install
)

git_download gappa

( cd "${CI_BUILD_DIR}/gappa"
  if [ ! -x ./configure ]; then
      autoconf
      ./configure
  fi
  ./remake "-j${NJOBS}"
  ./remake install
)
