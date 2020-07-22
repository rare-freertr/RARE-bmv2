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

      PI = super.callPackage ./PI { };
      bmv2 = super.callPackage ./bmv2 { };
      p4c = super.callPackage ./p4c { };
      p4runtime = super.callPackage ./p4runtime { };

    };
in [ overlay1 ]
