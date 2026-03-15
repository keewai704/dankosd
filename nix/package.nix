{ lib, stdenvNoCC, makeWrapper, quickshell ? null, version ? "unstable", dmsPath ? "/usr/share/quickshell/dms" }:

stdenvNoCC.mkDerivation {
  pname = "dankosd";
  inherit version;
  src = lib.cleanSource ../.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -d "$out/bin" "$out/share/dankosd/qml" "$out/share/dankosd/examples" "$out/lib/systemd/user"

    install -Dm755 bin/dankosd "$out/bin/dankosd"
    install -Dm644 qml/shell.qml "$out/share/dankosd/qml/shell.qml"
    install -Dm644 qml/LevelOSD.qml "$out/share/dankosd/qml/LevelOSD.qml"
    install -Dm644 qml/DdcOsdState.qml "$out/share/dankosd/qml/DdcOsdState.qml"
    install -Dm755 integrations/ddcfast_osd.sh "$out/share/dankosd/examples/ddcfast_osd.sh"
    install -Dm644 examples/hyprland/binds.conf "$out/share/dankosd/examples/hyprland-binds.conf"
    install -Dm644 systemd/dankosd.service "$out/lib/systemd/user/dankosd.service"

    ln -s dankosd "$out/bin/dms-ddc-osd"
    ln -s dankosd.service "$out/lib/systemd/user/dms-ddc-osd.service"

    for name in Common Widgets Services Modules Modals assets; do
      ln -s "${dmsPath}/$name" "$out/share/dankosd/qml/$name"
    done

    wrapProgram "$out/bin/dankosd" \
      --set DANKOSD_CONFIG_PATH "$out/share/dankosd/qml" \
      --set DANKOSD_DMS_PATH "${dmsPath}" \
      ${lib.optionalString (quickshell != null) "--prefix PATH : ${lib.makeBinPath [ quickshell ]}"}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Generic DMS-styled standalone OSD for Quickshell";
    homepage = "https://github.com/keewai704/dankosd";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
