{
  description = "A flake for presenterm presentation with chafa support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Define the packages we want
        packages = rec {
          # Simple wrapper script to run presenterm
          presenterm-runner = pkgs.writeShellScriptBin "presenterm-runner" ''
            exec ${pkgs.presenterm}/bin/presenterm main.md "$@"
          '';
          
          # Make the default package our wrapper
          default = presenterm-runner;
        };
        
        # Define the default app to run
        apps = rec {
          presenterm-runner = {
            type = "app";
            program = "${self.packages.${system}.presenterm-runner}/bin/presenterm-runner";
          };
          default = presenterm-runner;
        };

        # Define a development shell with both tools available
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.presenterm
            pkgs.chafa
          ];

          shellHook = ''
            echo "Presenterm and Chafa development environment ready!"
            echo "Run 'presenterm main.md' to start the presentation"
          '';
        };
      }
    );
}
