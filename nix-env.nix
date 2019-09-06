with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "RARE-nix-environment";
  buildInputs = [
    bmv2 p4c dpkg ethtool gcc gnumake telnet killall jre patchelf
  ];
  shellHook = ''
    cwd=$(pwd)
    cd 00-unit-labs/0000-topology/bin
    cp rawInt.bin.in rawInt.bin.nixos
    patchelf --set-interpreter ${glibc}/lib/ld-linux-* rawInt.bin.nixos
    cd $cwd
  '';
}
