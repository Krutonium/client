{
  pkgs,
  lib,
  stdenv,
  mkYarnPackage,
}: let
  packageJSON = builds.fromJSON (builtins.readFile ./package.json);
  version = packageJSON.version;

  nodeModules = mkYarnPackage {
    name = "SpaceBar Client";
    src = lib.cleanSourceWith {
      src = ./.;
      filter = name: type:
        builtins.any (x: baseNameOf name == x) ["package.json" "yarn.lock"];
      };
      publishBinsFor = ["webpack"];
    };

    gitignoreSource = pkgs.nix-gitignore.gitignoreSource;

  in
    stdenv.mkDerivation rec {
      pname = "SpaceBar Client";
      inherit version;
      src = gitignoreSource [] ./.;
      buildInputs = with pkgs; [
        nodeModules
        pkgs.yarn
     ];

     passthru = {
       inherit nodeModules;
     };

     patchPhase = ''
       ln -sf ${nodeModules}/libexec/*/node_modules .
     '';

     shellHook = ''
       ln -sf ${nodeModules}/libexec/*/node_modules ./web
     '';

     installPhase = ''
       yarn build:web
     '';
   }
