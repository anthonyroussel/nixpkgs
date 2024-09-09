import ../make-test-python.nix (
  { pkgs, lib, ... }:
  let
    domain = "EXAMPLE";
    realm = "EXAMPLE.LOCAL";
    password = "Passw0rd";

  in
  {
    name = "samba-ad-dc";
    meta.maintainers = [ lib.maintainers.anthonyroussel ];

    nodes = {
      dc =
        { ... }:
        {
          networking = {
            firewall.enable = false;
            hosts."127.0.0.1" = [
              "dc.${lib.toLower realm}"
              "DC"
            ];
            interfaces.eth1 = {
              ipv6.addresses = pkgs.lib.mkOverride 0 [
                {
                  address = "fd00::1";
                  prefixLength = 64;
                }
              ];
              ipv4.addresses = pkgs.lib.mkOverride 0 [
                {
                  address = "192.168.1.1";
                  prefixLength = 24;
                }
              ];
            };
            nameservers = [ "192.168.1.1" ];
            search = [ (lib.toLower realm) ];
            useDHCP = false;
          };

          services.samba = {
            enable = true;
            package = pkgs.samba4Full;

            ad-dc = {
              enable = true;
              ensureDomain = {
                inherit domain realm;
                enable = true;
                extraArgs = [
                  "--adminpass=${password}"
                  "--use-rfc2307"
                ];
              };
            };

            settings = {
              global = {
                inherit realm;
                "idmap_ldb:use rfc2307" = "yes";
                "netbios name" = "DC";
                "server role" = "active directory domain controller";
                workgroup = domain;
              };
              netlogon = {
                path = "/var/lib/samba/sysvol/${lib.toLower realm}/scripts";
                "read only" = "No";
              };
              sysvol = {
                path = "/var/lib/samba/sysvol";
                "read only" = "No";
              };
            };

            nmbd.enable = false;
            smbd.enable = false;
            winbindd.enable = false;
          };
        };

      client =
        { ... }:
        {
          networking = {
            firewall.enable = false;
            hosts."127.0.0.1" = [
              "client.${lib.toLower realm}"
              "client"
            ];
            interfaces.eth1 = {
              ipv6.addresses = pkgs.lib.mkOverride 0 [
                {
                  address = "fd00::2";
                  prefixLength = 64;
                }
              ];
              ipv4.addresses = pkgs.lib.mkOverride 0 [
                {
                  address = "192.168.1.2";
                  prefixLength = 24;
                }
              ];
            };
            nameservers = [ "192.168.1.1" ];
            search = [ (lib.toLower realm) ];
            useDHCP = false;
          };

          services.samba = {
            enable = true;
            settings = {
              global = {
                inherit realm;
                "client use kerberos" = "required";
                "idmap config * : backend" = "autorid";
                "idmap config * : range" = "1000000 - 19999999";
                "idmap config * : rangesize" = "1000000";
                "template homedir" = "/home/%U@%D";
                "template shell" = "/bin/bash";
                "winbind enum groups" = "no";
                "winbind enum users" = "no";
                "winbind use default domain" = false;
                security = "ads";
                workgroup = domain;
              };
            };
          };

          security.krb5 = {
            enable = true;
            settings = {
              libdefaults = {
                default_realm = realm;
                dns_lookup_kdc = true;
                dns_lookup_realm = true;
              };
            };
          };
        };
    };

    testScript = ''
      start_all()

      dc.wait_for_unit("samba-ad-dc-ensure-domain.service")
      dc.wait_for_unit("samba-ad-dc.service")
      dc.wait_for_open_port(88)

      with subtest("Check Active Directory domain information"):
        domain_info = dc.succeed("${pkgs.samba4Full}/bin/samba-tool domain info 127.0.0.1")
        assert "${domain}" in domain_info, f"expected '${domain}' in '{domain_info}'"

      client.wait_for_unit("network-online.target")

      with subtest("Check Kerberos authentication"):
        client.succeed("echo '${password}' | ${pkgs.krb5}/bin/kinit Administrator@${realm}")
        klist = client.succeed("${pkgs.krb5}/bin/klist")
        assert "krbtgt/EXAMPLE.LOCAL@EXAMPLE.LOCAL" in klist, f"expected 'krbtgt/EXAMPLE.LOCAL@EXAMPLE.LOCAL' in '{klist}'"

      with subtest("Check join Active Directory domain"):
        client.succeed("${pkgs.samba4Full}/bin/samba-tool domain join ${realm} MEMBER -U Administrator --realm=${realm} -W ${domain} --password=${password}")

      with subtest("Check computer has been created on DC"):
        computer_list = dc.succeed("${pkgs.samba4Full}/bin/samba-tool computer list")
        assert "CLIENT$" in computer_list, f"expected 'CLIENT$' in '{computer_list}'"
    '';
  }
)
