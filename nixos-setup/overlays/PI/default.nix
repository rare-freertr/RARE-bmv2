{ stdenv, fetchFromGitHub, autoreconfHook, pkg-config,
  python27, judy, protobuf3_6, boost, zlib, grpc, thrift }:

stdenv.mkDerivation rec {
  name = "PI-${version}";
  version = "41358da";

  src = fetchFromGitHub {
    owner = "p4lang";
    repo = "PI";
    rev = "${version}";
    fetchSubmodules = true;
    sha256 = "19s39yw8cl0ja0ghq780v721br42p0mx8rf94xl11bs31c6ijavd";
  };

  buildInputs = [ autoreconfHook python27 judy protobuf3_6 pkg-config
                  boost zlib grpc thrift ];

  configureFlags = [
    "--with-boost=${boost}"
    "--with-proto"
    "--without-internal-rpc"
    "--without-cli"
    "--without-bmv2"
    "--without-sysrepo"
  ];

  doCheck = true;
  ## Auto-detection of the check target fails ("make -n check"
  ## terminates with an error)
  checkTarget = "check";
}
