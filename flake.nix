{
  description =
    "Foo";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/23.05";
  inputs.llamacpp.url = "github:ggerganov/llama.cpp";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, llamacpp, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            lolcat
            figlet
            llamacpp.packages.${system}.default
            rlwrap
          ];
          shellHook = ''
            figlet  -f small -k "LLaMa env initiating"| lolcat -F 0.5 -ad 1 -s 30

            # get bash to behave a bit closer to zsh
            if [[ -z "$BASH" ]]; then
              bind 'set show-all-if-ambiguous on'
              bind 'set show-all-if-unmodified on'
              bind 'set menu-complete-display-prefix on'
              bind 'TAB:menu-complete'
            fi
          '';
        };
        packages.system.default = pkgs.stdenv.mkDerivation {
        };
      });

}
