with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "RARE-nix-environment";
  buildInputs = [
    bmv2 p4c dpkg ethtool gcc gnumake telnet killall jre patchelf
  ];
}
