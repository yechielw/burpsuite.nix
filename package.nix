{
  lib,
  buildFHSEnv,
  fetchurl,
  jdk,
  makeDesktopItem,
  unzip,
}:

let
  pname = "burpsuite";
  description = "Integrated platform for performing security testing of web applications";
  latestJson = builtins.fromJSON (builtins.readFile ./latest.json);
  version = latestJson.Version;
  releaseUrl = latestJson.ReleaseUrl or (
    "/burp/releases/professional-community-" + lib.replaceStrings [ "." ] [ "-" ] version
  );
  changelog =
    if lib.hasPrefix "https://" releaseUrl then
      releaseUrl
    else if lib.hasPrefix "/" releaseUrl then
      "https://portswigger.net${releaseUrl}"
    else
      "https://portswigger.net/burp/releases/${releaseUrl}";
  hash = builtins.convertHash {
    hash = latestJson.Sha256Checksum;
    toHashFormat = "sri";
    hashAlgo = "sha256";
  };

  src = fetchurl {
    name = "burpsuite.jar";
    urls = [
      "https://portswigger-cdn.net/burp/releases/download?product=desktop&version=${version}&type=Jar"
      "https://portswigger.net/burp/releases/download?product=desktop&version=${version}&type=Jar"
      "https://web.archive.org/web/https://portswigger.net/burp/releases/download?product=desktop&version=${version}&type=Jar"
    ];
    sha256 = hash;
  };

  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    desktopName = "Burp Suite Desktop";
    comment = description;
    categories = [
      "Development"
      "Security"
      "System"
    ];
  };

in
buildFHSEnv {
  inherit pname version;

  runScript = "${lib.getExe jdk} -jar ${src} --suppress-jre-check --i-accept-the-license-agreement --disable-check-for-updates-dialog --disable-auto-update";

  targetPkgs =
    pkgs: with pkgs; [
      alsa-lib
      at-spi2-core
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      gtk3-x11
      jython
      libcanberra-gtk3
      libdrm
      udev
      libxkbcommon
      libgbm
      nspr
      nss
      pango
      libX11
      libxcb
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
    ];

  extraInstallCommands = ''
    mkdir -p "$out/share/icons/hicolor/64x64/apps"
    ${lib.getBin unzip}/bin/unzip -p ${src} resources/Media/icon64pro.png > "$out/share/icons/hicolor/64x64/apps/${pname}.png"
    cp -r ${desktopItem}/share/applications $out/share
  '';

  meta = with lib; {
    inherit description;
    longDescription = ''
      Burp Suite is an integrated platform for performing security testing of web applications.
      Its various tools work seamlessly together to support the entire testing process, from
      initial mapping and analysis of an application's attack surface, through to finding and
      exploiting security vulnerabilities.
    '';
    homepage = "https://portswigger.net/burp/";
    inherit changelog;
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.unfree;
    platforms = jdk.meta.platforms;
    hydraPlatforms = [ ];
    maintainers = with maintainers; [
      bennofs
      fab
    ];
    mainProgram = "burpsuite";
  };
}
