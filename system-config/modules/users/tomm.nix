{ pkgs, ... }:
let
    secrets = import ../../secrets.nix;
in {
    users.users.tomm = {
        name = "tomm";
        description = secrets.names.tomm;
        isNormalUser = true;
        createHome = true;
        hashedPassword = secrets.passwords.tomm;
        home = "/home/tomm";
        shell = pkgs.fish;
        extraGroups = [ "wheel" "openrazer" "networkmanager" "scanner" "lp" "kvm" "input" "libvirtd" "gamemode" ];
    };

    programs.fish.enable = true;
}
