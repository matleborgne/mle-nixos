{ lib, stdenv, fetchzip, gettext }:

  stdenv.mkDerivation rec {
    pname = "cockpit-podman";
    version = "103";

    src = fetchzip {
      url = "https://github.com/cockpit-project/${pname}/releases/download/${version}/${pname}-${version}.tar.xz";
      sha256 = "sha256-0mdqa9w1p6cmli6976v4wi0sw9r4p5prkj7lzfd1877wk11c9c73=";
    };

    nativeBuildInputs = [
      gettext
    ];

    makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

    postPatch = ''
      substituteInPlace Makefile \
        --replace /usr/share $out/share
      touch pkg/lib/cockpit-po-plugin.js
      touch dist/manifest.json
    '';

    dontBuild = true;

    meta = with lib; {
      description = "Cockpit UI for podman containers";
      license = licenses.lgpl21;
      homepage = "https://github.com/cockpit-project/cockpit-podman";
      platforms = platforms.linux;
      maintainers = with maintainers; [ ];
    };
  }
