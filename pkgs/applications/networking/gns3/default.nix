{ callPackage
, libsForQt5
}:

let
  mkGui = args: callPackage (import ./gui/2.x.nix (args)) {
    inherit (libsForQt5) wrapQtAppsHook;
  };
  mkGuiPreview = args: callPackage (import ./gui/3.x.nix (args)) {
    inherit (libsForQt5) wrapQtAppsHook;
  };

  mkServer = args: callPackage (import ./server/2.x.nix (args)) { };
  mkServerPreview = args: callPackage (import ./server/3.x.nix (args)) { };

in {
  guiStable = mkGui {
    channel = "stable";
    version = "2.2.45";
    hash = "sha256-SMnhPz5zTPtidy/BIvauDM60WgDLG+NIr9rdUrQhz0A=";
  };

  guiPreview = mkGuiPreview {
    channel = "preview";
    version = "3.0.0b1";
    hash = "sha256-B2XS7PzvPjiRPtxyhQYEo5G4u29ABJK79PyY42yc45s=";
  };

  serverStable = mkServer {
    channel = "stable";
    version = "2.2.45";
    hash = "sha256-1GwhZEPfRW1e+enJipy7YOnA4QzeqZ7aCG92GrsZhms=";
  };

  serverPreview = mkServerPreview {
    channel = "preview";
    version = "3.0.0b1";
    hash = "sha256-j9cAy4UWfnfrA/RwDoMTI0QBgZzDu0Qrl+F6Oft8ktU=";
  };
}
