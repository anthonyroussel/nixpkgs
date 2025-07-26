{ pkgs, ... }:

{
    skipTypeCheck = true;

  name = "keystone";
  meta.maintainers = [ pkgs.lib.maintainers.anthonyroussel ];


  nodes.machine =
    { ... }:
    let
      tls-cert = "abc";
    in
    {
      services.keystone = {
        enable = true;
      };
    };


  # nodes =
  #   let
  #     sqlite = {
  #       services.keystone = {
  #         enable = true;
  #         port = 9001;
  #       };
  #     };
  #     postgres = {
  #       imports = [ sqlite ];
  #       services.mealie.database.createLocally = true;
  #     };
  #   in
  #   {
  #     inherit sqlite postgres;
  #   };

  testScript = ''
    machine.start()
    machine.wait_for_unit("keystone.service")
  '';

    # def test_mealie(node):
    #   node.wait_for_unit("mealie.service")
    #   node.wait_for_open_port(9001)
    #   node.succeed("curl --fail http://localhost:9001")

    # test_mealie(sqlite)
    # sqlite.send_monitor_command("quit")
    # sqlite.wait_for_shutdown()
    # test_mealie(postgres)
}
