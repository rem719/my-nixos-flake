{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  libx11,
  libxext,
  libxpm,
}:
stdenv.mkDerivation rec {
  pname = "wmnd";
  version = "0.4.18";

  src = fetchurl {
    url = "https://www.thregr.org/~wavexx/software/wmnd/releases/wmnd-${version}.tar.gz";
    hash = "sha256-Fjyv9v6W0UofdHFI9XZgeXGWSVYjcFqD+sxex1A7Qwc=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libx11
    libxext
    libxpm
  ];

  meta = with lib; {
    description = "Window Maker dockapp for monitoring network interfaces";
    homepage = "https://www.thregr.org/~wavexx/software/wmnd/";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
