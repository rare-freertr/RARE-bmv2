let
  grpc_version = "1.17.2";
  overlay1 = self: super:
    {
      grpc = super.grpc.overrideAttrs(oldAttrs: rec {
	version = grpc_version;
	name = "grpc-${version}";
	src = super.fetchFromGitHub {
	    owner = "grpc";
	    repo = "grpc";
	    rev = "v${version}";
	    sha256 = "1rq20951h5in3dy0waa60dsqj27kmg6ylp2gdsxyfrq5jarlj89g";
	};

	# grpc has a CMakefile and a standard (non-autoconf) Makefile. We
	# use cmake to build the package but that method does not support
	# pkg-config. We have to use the Makefile for that explicitely.
	postInstall = ''
	    cd ..
	    export BUILDDIR_ABSOLUTE=$out prefix=$out
	    make install-pkg-config_c
	    make install-pkg-config_cxx
	'';
      });

      thrift = super.thrift.overrideAttrs(oldAttrs: rec {
	version = "0.12.0";
	name = "thrift-${version}";

	src = super.fetchurl {
	    url = "https://archive.apache.org/dist/thrift/${version}/${name}.tar.gz";
	    sha256 = "0a04v7dgm1qzgii7v0sisnljhxc9xpq2vxkka60scrdp6aahjdn3";
	};

      });

      python = super.python.override {
	packageOverrides = python-self: python-super: {
	  scapy = python-super.scapy.overrideAttrs(oldAttrs: rec {
	    name = "scapy-${version}";
	    version = "2.4.0";

	    src = super.fetchFromGitHub {
	      owner = "secdev";
	      repo = "scapy";
	      rev = "v${version}";
	      fetchSubmodules = true;
	      sha256 = "1s6lkjm5l3vds0vj61qk1ma7jxdxr5ma9jcvzaw3akd69aah3b88";
	    };
	  });

	  grpcio = python-super.grpcio.overrideAttrs(oldAttrs: rec {
	    version = grpc_version;
	    name = "grpcio-${version}";
	    src = super.fetchFromGitHub {
	      owner = "grpc";
	      repo = "grpc";
	      rev = "v${version}";
	      fetchSubmodules = true;
	      sha256 = "03jyrbjqd57188cjllzh7py38cbdgpg6km0ys9afq8pvcqcji2kc";
	    };
	  });

	  nnpy = python-super.buildPythonPackage rec {
	    pname = "nnpy-python";
	    version = "1.4.2";

	    src = super.fetchFromGitHub {
	      owner = "nanomsg";
	      repo = "nnpy";
	      rev = version;
	      sha256 = "1ffqf3xxx30xjpxviqxrymprl78pshzji8pskz8164s7w4fv6fyd";
	    };

	    buildInputs = [ super.nanomsg python-super.cffi ];

	    LD_LIBRARY_PATH = super.stdenv.lib.makeLibraryPath [ super.nanomsg ];

	    patchPhase = ''
	      substituteInPlace generate.py --replace /usr/include ${super.nanomsg}/include
	    '';

	    meta = with super.stdenv.lib; {
	      description = "cffi-based Bindings for nnpy";
	    };
	  };
	};
      };

      p4runtime = super.stdenv.mkDerivation rec {
	name = "p4runtime-${version}";
	version = "1.0.0";

	src = super.fetchFromGitHub {
	  owner = "p4lang";
	  repo = "p4runtime";
	  rev = "v${version}";
	  sha256 = "0v67jxb8fd5pkdl954vcj7dnk8b0y9949bxak9xkj5ahfifrp90i";
	};

	googleapis = super.fetchFromGitHub {
	  owner = "googleapis";
	  repo = "googleapis";
	  rev = "common-protos-1_3_1";
	  sha256 = "1br13nv5higsad5509sp6nsgz2bgjdpi1l7bk579d2ngkbfn73sh";
	};

	patch = super.lib.writeText "p4runtime-compile-patch" ''
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

	buildInputs = (with super; [ protobuf which git googleapis ])
		      ++ (with self; [ grpc ]);

	patches = [ patch ];

	phases = [ "unpackPhase" "patchPhase" "buildPhase" ];

	GOOGLE_PROTO_DIR = "${googleapis}";
	buildPhase = ''
	  substituteInPlace CI/compile_protos.sh --replace '#!/usr/bin/env bash' ${super.bash}/bin/bash
	  CI/compile_protos.sh $out
	  mkdir $out/source
	  cp -r ${src}/* $out/source
	'';

      };

      PI = super.callPackage ./PI { };
      bmv2 = super.callPackage ./bmv2 { };
      p4c = super.callPackage ./p4c { };

    };
in [ overlay1 ]
