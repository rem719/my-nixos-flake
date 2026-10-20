{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
  xorg,
}:
stdenv.mkDerivation rec {
  pname = "wmbatteries";
  version = "0.1.7"; # Latest version mentioned in the repo

  src = fetchFromGitHub {
    owner = "tarjanm-movidius";
    repo = "wmbatteries";
    rev = "master";
    # We leave the hash empty so Nix can calculate it for us during the first build attempt
    hash = "sha256-0KQ+JmWvBWkmbX0YQh8wOoKDofj/fqaMTuOMheJwq6w=";
  };

  # nativeBuildInputs are tools used to build the software
  # The autoreconfHook automatically handles autogen.sh / configure.ac setup
  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  # buildInputs are the libraries the software needs to run
  # Standard dependencies for X11 dockapps
  buildInputs = [
    xorg.libX11
    xorg.libXext
    xorg.libXpm
  ];

  meta = with lib; {
    description = "Window Maker dockapp to monitor up to 2 battery capacities and CPU temperature";
    homepage = "https://github.com/tarjanm-movidius/wmbatteries";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
