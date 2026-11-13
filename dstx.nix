{pkgs, ...}: let
  dstxPackage = pkgs.stdenvNoCC.mkDerivation {
    pname = "dstx";
    version = "0.7.0";
    src = builtins.path {
      path = ./dstx-0.7.0_x86_64;
      name = "dstx-0.7.0_x86_64";
    };
    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      install -Dm755 "$src/dstx" "$out/bin/dstx"
      install -Dm755 "$src/dstx-dbus" "$out/bin/dstx-dbus"
      mkdir -p "$out/share/dbus-1/system.d"
      cat > "$out/share/dbus-1/system.d/org.dstx.Bridge.conf" <<'EOF'
      <!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
       "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
      <busconfig>
        <policy group="dstx">
          <allow own="org.dstx.Bridge"/>
          <allow send_destination="org.dstx.Bridge"/>
          <allow receive_sender="org.dstx.Bridge"/>
        </policy>
        <policy user="root">
          <allow own="org.dstx.Bridge"/>
        </policy>
      </busconfig>
      EOF
    '';
  };
in {
  boot.kernelModules = ["uinput"];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0660", GROUP="dstx"
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0660", GROUP="dstx"
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0660", GROUP="dstx"
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", GROUP="dstx"
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", GROUP="dstx"
    KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0660", GROUP="dstx"
    KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2017", MODE="0660", GROUP="dstx"
    KERNEL=="uinput", MODE="0660", GROUP="dstx", OPTIONS+="static_node=uinput"
  '';

  users.groups.dstx = {};
  users.users.hexlyn.extraGroups = ["dstx"];

  services.dbus.packages = [dstxPackage];

  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.systemd1.manage-units" ||
           action.id == "org.freedesktop.systemd1.manage-unit-files") &&
          action.lookup("unit") == "dstx-daemon.service" &&
          subject.isInGroup("dstx")) {
        return polkit.Result.YES;
      }
    });
  '';

  systemd.services.dstx-daemon = {
    description = "DSTX Daemon Service";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/rm -f /dev/shm/dstx_shared_mem";
      ExecStart = "${dstxPackage}/bin/dstx --daemon";
      ExecStartPost = "${pkgs.coreutils}/bin/sleep 0.1";
      Restart = "on-failure";
      RestartSec = "1s";
      User = "root";
      Group = "dstx";
      LimitMEMLOCK = "infinity";
      Nice = -20;
      CPUSchedulingPolicy = "fifo";
      CPUSchedulingPriority = 99;
    };
  };

  systemd.services.dstx-dbus = {
    description = "DSTX D-Bus Bridge";
    wantedBy = ["multi-user.target"];
    after = ["network.target" "dstx-daemon.service"];
    requires = ["dstx-daemon.service"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${dstxPackage}/bin/dstx-dbus";
      Restart = "always";
      RestartSec = "2s";
      User = "root";
      Group = "dstx";
    };
  };

  environment.systemPackages = [dstxPackage];
}
