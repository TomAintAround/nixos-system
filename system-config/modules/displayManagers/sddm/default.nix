{pkgs, ...}: let
  customTheme = pkgs.sddm-astronaut.override {
    themeConfig = {
      DateFormat = "dd/MM/yyyy";

      HeaderText = "Bem vindo!";

      Background = "/etc/nixos/system-config/modules/sddm/Backgrounds/MountainsNight.jpg";

      HeaderTextColor = "#cdd6f4";
      DateTextColor = "#cdd6f4";
      TimeTextColor = "#cdd6f4";

      FormBackgroundColor = "#1e1e2e";
      BackgroundColor = "#181825";
      DimBackgroundColor = "#181825";

      LoginFieldBackgroundColor = "#11111b";
      PasswordFieldBackgroundColor = "#11111b";
      LoginFieldTextColor = "#cdd6f4";
      PasswordFieldTextColor = "#cdd6f4";
      UserIconColor = "#cdd6f4";
      PasswordIconColor = "#cdd6f4";

      PlaceholderTextColor = "#bac2de";
      WarningColor = "#f38ba8";

      LoginButtonTextColor = "#cdd6f4";
      LoginButtonBackgroundColor = "#11111b";
      SystemButtonsIconsColor = "#a6adc8";
      SessionButtonTextColor = "#a6adc8";
      VirtualKeyboardButtonTextColor = "#a6adc8";

      DropdownTextColor = "#cdd6f4";
      DropdownSelectedBackgroundColor = "#11111b";
      DropdownBackgroundColor = "#1e1e2e";

      HighlightTextColor = "#89dceb";
      HighlightBackgroundColor = "#11111b";
      HighlightBorderColor = "#11111b";

      HoverUserIconColor = "#89dceb";
      HoverPasswordIconColor = "#89dceb";
      HoverSystemButtonsIconsColor = "#89dceb";
      HoverSessionButtonTextColor = "#89dceb";
      HoverVirtualKeyboardButtonTextColor = "#89dceb";

      PartialBlur = true;
      FullBlur = false;
      HaveFormBackground = true;

      FormPosition = "right";

      AllowEmptyPassword = true;
      AllowUppercaseLettersInUsernames = true;
    };
  };
in {
  services.displayManager = {
    sddm = {
      enable = true;
      package = pkgs.kdePackages.sddm;
      autoNumlock = true;
      enableHidpi = true;
      wayland.enable = true;
      extraPackages = [customTheme];
      theme = "${customTheme}/share/sddm/themes/sddm-astronaut-theme";
    };
  };
}
