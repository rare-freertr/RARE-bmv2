{ stdenv, fetchFromGitHub, cmake, pkgconfig, python27, flex, bison,
  protobuf3_6, boost, gmp, doxygen, llvm,
  gmock, clang, libpcap, libelf, iproute,
  nettools, python27Packages, bmv2, thrift, boehmgc,
  pythonPackages }:

stdenv.mkDerivation rec {
  name = "p4c-${version}";
  version = "d4714270";

  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "p4c";
    rev = "d47142709a6c1f9ceb3f7a779cc5c220f0712f05";
    fetchSubmodules = true;
    sha256 = "0a93lqld4l6dvb41f258zkqxrf241q165v1sw4h1433a0w14h7n3";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ pkgconfig python27 flex bison protobuf3_6 boost gmp doxygen llvm gmock
                  clang libpcap libelf iproute nettools iproute bmv2 thrift boehmgc ]
                ++ (with pythonPackages; [ ipaddr ply scapy ]);

  cmakeFlags = [
  ];

  preConfigure = ''
    cmakeFlagsArray=(
      $cmakeFlagsArray
        "-DCMAKE_INSTALL_PREFIX=$out"
    )
  '';

  doCheck = true;

  preCheck = ''
    patchShebangs .
    patchShebangs ../backends
    patchShebangs ../test
    patchShebangs ../tools
    _cwd=$(pwd)
    cd ../backends/ebpf/runtime
    echo "override CFLAGS += -fno-stack-protector" >kernel.mk.new
    cat kernel.mk >>kernel.mk.new
    mv kernel.mk.new kernel.mk
    cd $_cwd
  '';
}
