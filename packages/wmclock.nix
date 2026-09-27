{ lib
, stdenv
, fetchurl
, autoreconfHook
, pkg-config
, libX11
, libXext
, libXpm
, autoconf
, automake
}:

stdenv.mkDerivation rec {
  pname = "wmclock";
  version = "1.0.16";

  src = fetchurl {
    url = "https://www.dockapps.net/download/wmclock-${version}.tar.gz";
    hash = "sha256-P4u13zFg1ZGdGc8m1FRJ5uEmDSovSF5h815kpJY5otM=";
  };

  nativeBuildInputs = [
     autoconf
     automake
     pkg-config

  ];

  buildInputs = [
    libX11
    libXext
    libXpm
  ];

configurePhase = ''
    autoreconf -fi
    ./configure --prefix=$out
  '';

  meta = {
    description = "Clock dockapp for Window Maker";
    homepage = "https://www.dockapps.net/wmclock";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
}
