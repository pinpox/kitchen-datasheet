# {
#   description = "Kitchen Datasheet website";

#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#     flake-utils.url = "github:numtide/flake-utils";

#     flake-compat = {
#       url = "github:edolstra/flake-compat";
#       flake = false;
#     };
#   };

#   outputs = { self, nixpkgs, flake-utils, ... }:

#     flake-utils.lib.eachDefaultSystem (system:
#       let
#         pkgs = nixpkgs.legacyPackages.${system};
#       in
#       rec {

#         packages = flake-utils.lib.flattenTree rec {

#           blog = pkgs.stdenv.mkDerivation rec {
#             pname = "pinpox-blog";
#             version = "1.0";

#             src = self;
#             buildPhase = ''
#               ${pkgs.zola}/bin/zola build
#             '';

#             installPhase = ''
#               runHook preInstall
#               cp -r public $out
#               runHook postInstall
#             '';

#             meta = with pkgs.lib; {
#               homepage = "TODO";
#               description = "TODO";
#               license = licenses.mit;
#               maintainers = [ maintainers.pinpox ];
#             };
#           };

#         };
#         defaultPackage = packages.blog;
#       });
# }


{
  description = "A simple Go package";

  # Nixpkgs / NixOS version to use.
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-pinpox.url = "github:pinpox/nixpkgs/mdbook-cmdrun";
    # mdbook-cmdrun.url = "github:FauconFan/mdbook-cmdrun";
    # mdbook-cmdrun.flake = false;
  };


  outputs = { self, nixpkgs, nixpkgs-pinpox }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      nixpkgsPinpoxFor = forAllSystems (system: import nixpkgs-pinpox { inherit system; });

    in
    {

      # Provide some binary packages for selected system types.
      packages = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
            pkgs-pinpox = nixpkgsPinpoxFor.${system};
          in
          {
            bash-example = pkgs.writeShellScriptBin "example-script" ''
              echo test
            '';

            book = pkgs.stdenv.mkDerivation {

              name = "book";
              src = ./.;
              buildPhase = '' '';

              installPhase = ''
                runHook preInstall
                mdbook build -d $out
                runHook postInstall
              '';

              buildInputs = [ pkgs.mdbook pkgs-pinpox.mdbook-cmdrun ];

              meta = with pkgs.lib; {
                homepage = "TODO";
                description = "TODO";
                license = licenses.mit;
                maintainers = [ maintainers.pinpox ];
              };

            };

            go-hello = pkgs.buildGoModule {
              pname = "go-hello";
              inherit version;
              # In 'nix develop', we don't need a copy of the source tree
              # in the Nix store.
              src = ./.;

              # This hash locks the dependencies of this package. It is
              # necessary because of how Go requires network access to resolve
              # VCS.  See https://www.tweag.io/blog/2021-03-04-gomod2nix/ for
              # details. Normally one can build with a fake sha256 and rely on native Go
              # mechanisms to tell you what the hash should be or determine what
              # it should be "out-of-band" with other tooling (eg. gomod2nix).
              # To begin with it is recommended to set this, but one must
              # remeber to bump this hash when your dependencies change.
              #vendorSha256 = pkgs.lib.fakeSha256;

              vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
            };
          });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.book);
    };
}
