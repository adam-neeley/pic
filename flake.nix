{
  description = "pic";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems
        (system: f { pkgs = import nixpkgs { inherit system; }; });
      serverName = "Fusion";
      serverUrl = "fusion.humboldt.edu";
      mountPath = "./public";
    in {
      packages = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.python3Packages.buildPythonPackage {
          propogatedBuildInputs = with pkgs.python3Packages; [ setuptools ];
          pname = "pic";
          version = "0.1";
          meta.mainProgram = "main.py";
          src = ./.;
        };
      });
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          venvDir = ".venv";
          packages = with pkgs;
            [
              sshfs
              eza
              (writeShellScriptBin "connect-${serverName}" ''
                echo "Connecting to ${serverName}..."
                ssh atn22@${serverUrl} -i /home/adam/.ssh/adam@iron
              '')
              python311
            ] ++ (with pkgs.python311Packages; [ pip venvShellHook ]);
        };
      });
    };
}
