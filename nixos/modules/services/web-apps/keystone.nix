{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.keystone;
  pkg = cfg.package;
in
{
  options.services.keystone = {
    enable = lib.mkEnableOption "OpenStack Keystone";

    package = lib.mkPackageOption pkgs "openstack-keystone" { };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.keystone =
      let
        commandArgs = lib.cli.toGNUCommandLineShell { } {
          config = "/etc/gns3/gns3_server.conf";
          pid = "/run/gns3/server.pid";
          log = cfg.log.file;
          ssl = cfg.ssl.enable;
          # These are implicitly not set if `null`
          certfile = cfg.ssl.certFile;
          certkey = cfg.ssl.keyFile;
        };
      in
      {
        # [Unit]
        # Description=OpenStack Keystone API (keystone)
        # After=postgresql.service mysql.service keystone.service rabbitmq-server.service ntp.service network-online.target local-fs.target remote-fs.target
        # Wants=postgresql.service mysql.service keystone.service rabbitmq-server.service ntp.service network-online.target

        # Documentation=man:keystone(1)

        # [Service]

        # [Install]
        # WantedBy=multi-user.target

        description = "OpenStack Keystone API (keystone)";
        after = [
          "network.target"
          "network-online.target"
        ];
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];

        # configFile cannot be stored in RuntimeDirectory, because GNS3
        # uses the `--config` base path to stores supplementary configuration files at runtime.
        #
        # preStart = ''
        #   install -m660 ${configFile} /etc/gns3/gns3_server.conf

        #   ${lib.optionalString cfg.auth.enable ''
        #     ${pkgs.replace-secret}/bin/replace-secret \
        #       '@AUTH_PASSWORD@' \
        #       "''${CREDENTIALS_DIRECTORY}/AUTH_PASSWORD" \
        #       /etc/gns3/gns3_server.conf
        #   ''}
        # '';

        # path = lib.optional flags.enableLibvirtd pkgs.qemu;

        # reloadTriggers = [ configFile ];

        serviceConfig = {
          User = "keystone";
          Group = "keystone";
          Type = "simple";
          RuntimeDirectory = "keystone lock/keystone";
          ExecStart = "${lib.getExe cfg.package} systemd-start";
          Restart = "on-failure";
          LimitNOFILE = 65535;
          TimeoutStopSec = 15;

          # User=keystone
          # Group=keystone
          # Type=simple
          # WorkingDirectory=~
          # RuntimeDirectory=keystone lock/keystone
          # CacheDirectory=keystone
          # ExecStart=/etc/init.d/keystone systemd-start
          # Restart=on-failure
          # LimitNOFILE=65535
          # TimeoutStopSec=15

          # ConfigurationDirectory = "gns3";
          # ConfigurationDirectoryMode = "0750";
          # Environment = "HOME=%S/gns3";
          # ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          # ExecStart = "${lib.getExe cfg.package} ${commandArgs}";
          # Group = "gns3";
          # LimitNOFILE = 16384;
          # LoadCredential = lib.mkIf cfg.auth.enable [ "AUTH_PASSWORD:${cfg.auth.passwordFile}" ];
          # LogsDirectory = "gns3";
          # LogsDirectoryMode = "0750";
          # PIDFile = "/run/gns3/server.pid";
          # Restart = "on-failure";
          # RestartSec = 5;
          # RuntimeDirectory = "gns3";
          # StateDirectory = "gns3";
          # StateDirectoryMode = "0750";
          # SupplementaryGroups =
          #   lib.optional flags.enableDocker "docker"
          #   ++ lib.optional flags.enableLibvirtd "libvirtd"
          #   ++ lib.optional cfg.ubridge.enable "ubridge";
          # User = "gns3";
          # WorkingDirectory = "%S/gns3";

          # # Required for ubridge integration to work
          # #
          # # GNS3 needs to run SUID binaries (ubridge)
          # # but NoNewPrivileges breaks execution of SUID binaries
          # DynamicUser = false;
          # NoNewPrivileges = false;
          # RestrictSUIDSGID = false;
          # PrivateUsers = false;

          # # Hardening
          # DeviceAllow = [
          #   # ubridge needs access to tun/tap devices
          #   "/dev/net/tap rw"
          #   "/dev/net/tun rw"
          # ]
          # ++ lib.optionals flags.enableLibvirtd [
          #   "/dev/kvm"
          # ];
          # DevicePolicy = "closed";
          # LockPersonality = true;
          # MemoryDenyWriteExecute = true;
          # PrivateTmp = true;
          # # Don't restrict ProcSubset because python3Packages.psutil requires read access to /proc/stat
          # # ProcSubset = "pid";
          # ProtectClock = true;
          # ProtectControlGroups = true;
          # ProtectHome = true;
          # ProtectHostname = true;
          # ProtectKernelLogs = true;
          # ProtectKernelModules = true;
          # ProtectKernelTunables = true;
          # ProtectProc = "invisible";
          # ProtectSystem = "strict";
          # RestrictAddressFamilies = [
          #   "AF_INET"
          #   "AF_INET6"
          #   "AF_NETLINK"
          #   "AF_UNIX"
          #   "AF_PACKET"
          # ];
          # RestrictNamespaces = true;
          # RestrictRealtime = true;
          # UMask = "0022";
        };
      };
    # systemd.services.keystone = {
    #   description = "keystone, a self hosted recipe manager and meal planner";

    #   after = [ "network-online.target" ] ++ lib.optional cfg.database.createLocally "postgresql.target";
    #   requires = lib.optional cfg.database.createLocally "postgresql.target";
    #   wants = [ "network-online.target" ];
    #   wantedBy = [ "multi-user.target" ];

    #   environment = {
    #     PRODUCTION = "true";
    #     API_PORT = toString cfg.port;
    #     BASE_URL = "http://localhost:${toString cfg.port}";
    #     DATA_DIR = "/var/lib/keystone";
    #     NLTK_DATA = pkgs.nltk-data.averaged-perceptron-tagger-eng;
    #   }
    #   // (builtins.mapAttrs (_: val: toString val) cfg.settings);

    #   serviceConfig = {
    #     DynamicUser = true;
    #     User = "keystone";
    #     ExecStartPre = "${pkg}/libexec/init_db";
    #     ExecStart = "${lib.getExe pkg} -b ${cfg.listenAddress}:${builtins.toString cfg.port}";
    #     EnvironmentFile = lib.mkIf (cfg.credentialsFile != null) cfg.credentialsFile;
    #     StateDirectory = "keystone";
    #     StandardOutput = "journal";
    #   };
    # };

    # services.keystone.settings = lib.mkIf cfg.database.createLocally {
    #   DB_ENGINE = "postgres";
    #   POSTGRES_URL_OVERRIDE = "postgresql://keystone:@/keystone?host=/run/postgresql";
    # };

    # services.postgresql = lib.mkIf cfg.database.createLocally {
    #   enable = true;
    #   ensureDatabases = [ "keystone" ];
    #   ensureUsers = [
    #     {
    #       name = "keystone";
    #       ensureDBOwnership = true;
    #     }
    #   ];
    # };
  };
}
