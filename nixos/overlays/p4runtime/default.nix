{ stdenv, fetchFromGitHub, protobuf, which, git, grpc, writeText, bash }:

stdenv.mkDerivation rec {
  name = "p4runtime-${version}";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "p4runtime";
    rev = "v${version}";
    sha256 = "0vqmj17sgfjjppygw44vgl2limqj0rbfpfhhw6rwhc2w94xrac7i";
  };

  googleapis = fetchFromGitHub {
    owner = "googleapis";
    repo = "googleapis";
    rev = "common-protos-1_3_1";
    sha256 = "1br13nv5higsad5509sp6nsgz2bgjdpi1l7bk579d2ngkbfn73sh";
  };

  patch = writeText "p4runtime-compile-patch" ''
    --- orig/CI/compile_protos.sh   1970-01-01 00:00:01.000000000 +0000
    +++ source/CI/compile_protos.sh 2019-08-21 12:32:27.741970829 +0000
    @@ -33,12 +33,6 @@
     THIS_DIR=$(cd "$( dirname "$${BASH_SOURCE[0]}" )" && pwd)
     PROTO_DIR=$THIS_DIR/../proto

    -tmpdir=$(mktemp -d)
    -pushd $tmpdir > /dev/null
    -git clone --depth 1 https://github.com/googleapis/googleapis.git
    -popd > /dev/null
    -GOOGLE_PROTO_DIR=$tmpdir/googleapis
    -
     PROTOS="\
     $PROTO_DIR/p4/v1/p4data.proto \
     $PROTO_DIR/p4/v1/p4runtime.proto \
  '';

  buildInputs = [ protobuf which git googleapis grpc ];

  patches = [ patch ];

  phases = [ "unpackPhase" "patchPhase" "buildPhase" ];

  GOOGLE_PROTO_DIR = "${googleapis}";
  buildPhase = ''
    substituteInPlace CI/compile_protos.sh --replace '#!/usr/bin/env bash' ${bash}/bin/bash
    CI/compile_protos.sh $out
    mkdir $out/source
    cp -r ${src}/* $out/source
  '';
}
