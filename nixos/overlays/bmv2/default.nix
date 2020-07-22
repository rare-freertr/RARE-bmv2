{ stdenv, fetchFromGitHub, autoreconfHook, pkgconfig,
  boost, nanomsg, judy, gmp, python27, libpcap, protobuf3_6,
  zlib, thrift, PI, grpc, python27Packages, makeWrapper }:

stdenv.mkDerivation rec {
  name = "bmv2-${version}";
  version = "b447ac4";

  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "behavioral-model";
    rev = "${version}";
    sha256 = "1ivngk56yxy5x74giwhqaavappyk46qwk8rhky8m0s04z0gwh05s";
  };

  enableParallelBuilding = true;
  nativeBuildInputs = [ autoreconfHook pkgconfig ];
  buildInputs = [ boost nanomsg judy gmp python27 libpcap nanomsg protobuf3_6 zlib
                  PI grpc makeWrapper ]
                ++ (with python27Packages; [ six ]);
  propagatedBuildInputs = [ thrift ] ++ (with python27Packages; [ ipaddr ]);

  preAutoreconf = ''
    patchShebangs ./autogen.sh
    patchShebangs ./tools
  '';

  postAutoreconf = ''
    cd targets/simple_switch_grpc
    pwd
    autoreconf ''${autoreconfFlags:---install --force --verbose};
    cd ../..
  '';

  ## Turning off omptimizarion generates warnings from glibc:
  ## _FORTIFY_SOURCE requires compiling with optimization (-O) [-Wcpp]
  ## Not sure whether that's a problem
  #CXXFLAGS="-O0 -g";

  configureFlags = [
    "--with-pdfixed"
    "--with-pi"
    "--enable-debugger"
    "--with-thrift"
    "--with-nanomsg"
  ];

  postConfigure = ''
    cd targets/simple_switch_grpc
    ./configure --without-sysrepo --with-thrift --prefix=$out
    cd ../..
  '';

  postBuild = ''
    cd targets/simple_switch_grpc
    ## Missing -l should be fixed in Makefile.am
    make ''${enableParallelChecking:+-j''${NIX_BUILD_CORES} -l''${NIX_BUILD_CORES}} LIBS=-lpip4info
    cd ../..
  '';

  postInstall = ''
    wrapProgram $out/bin/simple_switch_CLI --set PYTHONPATH "$PYTHONPATH"
    cd targets/simple_switch_grpc
    make install
    cd ../..
  '';

  doCheck = true;
  checkTarget = "check";
  preCheck = ''
    patchShebangs targets
  '';
  postCheck = ''
    cd targets/simple_switch_grpc
    make ''${enableParallelChecking:+-j''${NIX_BUILD_CORES} -l''${NIX_BUILD_CORES}} check
    cd ../..
  '';
}
