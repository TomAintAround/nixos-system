{ lib, ... }: {
    services.fprintd.enable = true;

    security.pam.services.sddm.text = lib.mkBefore ''
        auth	[success=1 new_authtok_reqd=1 default=ignore]	pam_unix.so try_first_pass likeauth nullok
        auth	sufficient	pam_fprintd.so
    '';
}
