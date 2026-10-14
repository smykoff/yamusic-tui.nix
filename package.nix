{ lib
, stdenv
, fetchurl
, autoPatchelfHook
  # Runtime libraries (Linux). The executable links against libasound and libc.
, alsa-lib
}:

let
  inherit (stdenv.hostPlatform) system;

  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  platformSrc = sources.${system}
    or (throw "yamusic-tui: unsupported system ${system}");
in
stdenv.mkDerivation {
  pname = "yamusic-tui";
  version = sources.version;

  src = fetchurl { inherit (platformSrc) url hash; };

  # Upstream ships a bare, dynamically linked ELF executable (not an archive),
  # so there is nothing to unpack or build.
  dontUnpack = true;
  dontBuild = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ alsa-lib stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/yamusic-tui"
    runHook postInstall
  '';

  meta = {
    description = "Unofficial Yandex Music terminal client";
    homepage = "https://github.com/DECE2183/yamusic-tui";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "yamusic-tui";
  };
}
