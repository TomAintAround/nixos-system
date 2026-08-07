{
  pkgs,
  config,
  inputs,
  defaultSopsFile,
  ...
}: {
  imports = [inputs.sops-nix.homeManagerModules.sops];

  home.packages = with pkgs; [age sops];

  sops = {
    inherit defaultSopsFile;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

    secrets."mpdscribblePassword" = {};
  };
}
