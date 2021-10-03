#!/usr/bin/env bash

set -e

ci_dir="$(dirname "$0")"
. "${ci_dir}/ci-common.sh"

git_download flocq

( cd "${CI_BUILD_DIR}/flocq"
  if ! [ -x ./configure ]; then
      autoconf
      ./configure COQEXTRAFLAGS="-compat 8.13";
  fi
  ./remake "-j${NJOBS}"
  ./remake install
)
