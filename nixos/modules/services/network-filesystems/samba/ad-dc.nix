{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.samba.ad-dc;

in
{
  meta = {
    doc = ./samba.md;
    maintainers = [ lib.maintainers.anthonyroussel ];
  };

  options = {
    services.samba.ad-dc = {
      enable = lib.mkEnableOption "Samba AD DC Daemon.";

      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Extra arguments to pass to the samba service.";
        apply = lib.escapeShellArgs;
      };

      ensureDomain = lib.mkOption {
        type = lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "enable samba-tool domain auto-provision.";
            domain = lib.mkOption {
              type = lib.types.str;
              description = "NetBIOS domain name to use";
              example = "EXAMPLE";
            };
            realm = lib.mkOption {
              type = lib.types.str;
              description = "Realm name to use";
              example = "EXAMPLE.LOCAL";
            };
            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "Extra arguments to pass to the samba-tool domain provision executable.";
              default = [ ];
              example = [ "--use-rfc2307" ];
              apply = lib.escapeShellArgs;
            };
          };
        };
        description = "Ensure that the specified Samba AD DC domain exist.";
        default = { };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = !config.services.samba.nmbd.enable;
            message = "Samba AD DC cannot work with Samba NMBD daemon enabled.";
          }
          {
            assertion = !config.services.samba.smbd.enable;
            message = "Samba AD DC cannot work with Samba SMBD daemon enabled.";
          }
          {
            assertion = !config.services.samba.winbindd.enable;
            message = "Samba AD DC cannot work with Samba Winbindd daemon enabled.";
          }
        ];
      }

      {
        systemd.services.samba-ad-dc = {
          description = "Samba AD DC Daemon";
          documentation = [
            "man:samba(8)"
            "man:samba(7)"
            "man:smb.conf(5)"
          ];

          after = [
            "network.target"
            "network-online.target"
          ];

          partOf = [ "samba.target" ];
          wantedBy = [ "samba.target" ];
          wants = [ "network-online.target" ];

          serviceConfig = {
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
            ExecStart = "${config.services.samba.package}/sbin/samba --foreground --no-process-group ${cfg.extraArgs}";
            LimitNOFILE = 16384;
            PIDFile = "/run/samba/samba.pid";
            Slice = "system-samba.slice";
            Type = "notify";
          };

          unitConfig.RequiresMountsFor = "/var/lib/samba";
        };
      }

      (lib.mkIf cfg.ensureDomain.enable {
        systemd.services.samba-ad-dc.after = [ "samba-ad-dc-ensure-domain.service" ];
        systemd.services.samba-ad-dc-ensure-domain = {
          description = "Ensure NixOS-configured Samba AD DC domain";
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };

          script = lib.concatStringsSep "\n" [
            ''
              if [[ -d /var/lib/samba/sysvol/${lib.toLower cfg.ensureDomain.realm} ]]; then
                echo "Domain ${cfg.ensureDomain.realm} is already configured, cannot continue."
                exit 0
              fi
            ''
            ''
              ${config.services.samba.package}/bin/samba-tool domain provision \
                --realm=${cfg.ensureDomain.realm} \
                --domain=${cfg.ensureDomain.domain} \
                ${cfg.ensureDomain.extraArgs}
            ''
          ];
        };
      })
    ]
  );
}
