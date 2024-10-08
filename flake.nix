{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        package-name = "literate-markdown";
      in
      {
        devShell = pkgs.mkShell { buildInputs = [ pkgs.zig ]; };
        packages.default = pkgs.runCommand package-name { } ''
          mkdir $out/bin $out/lib -p
          ${pkgs.zig}/bin/zig build-exe -OReleaseFast -Mroot=${./src/main.zig} --cache-dir $TEMP --global-cache-dir $TEMP --name ${package-name} -femit-bin=$out/bin/${package-name}
        '';
      }
    );
}
