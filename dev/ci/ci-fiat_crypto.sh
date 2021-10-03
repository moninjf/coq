#!/usr/bin/env bash

set -e

ci_dir="$(dirname "$0")"
. "${ci_dir}/ci-common.sh"

FORCE_GIT=1
git_download fiat_crypto

# We need a larger stack size to not overflow ocamlopt+flambda when
# building the executables.
# c.f. https://github.com/coq/coq/pull/8313#issuecomment-416650241
stacksize=32768

# fiat-crypto is not guaranteed to build with the latest version of
# bedrock2, so we use the pinned version of bedrock2, but the external
# version of other developments
make_args=(EXTERNAL_REWRITER=1 EXTERNAL_COQPRIME=1)

( cd "${CI_BUILD_DIR}/fiat_crypto"
  git submodule update --init --recursive
  ulimit -s $stacksize
  make "${make_args[@]}" pre-standalone-extracted printlite lite
  make -j 1 "${make_args[@]}" all-except-compiled
)
