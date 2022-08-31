{
  inputs = rec {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";

    hydrajoy_src.url = "github:yomboprime/hydrajoy";
    hydrajoy_src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, hydrajoy_src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = hydrajoy;

          hydrajoy = pkgs.stdenv.mkDerivation rec {
            pname = "hydrajoy";
            version = "0.0";

            src = hydrajoy_src;

            postPatch = ''
              substituteInPlace src/Makefile \
                --replace 'gcc' '$(CXX)'
            '';

            buildPhase = ''
              rm src/hydrajoy64
              make -C src
            '';

            installPhase = ''
              mkdir -p $out/bin
              install src/hydrajoy64 $out/bin/

              mkdir -p $out/lib
              cp -vr lib/sixense/lib/linux_x64/release/. -t $out/lib
            '';

            buildInputs = [
              pkgs.linuxHeaders
            ];
          };
        };
      }
    );
}
