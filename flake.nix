{
  description = "Kitchen Datasheet website";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

  };


  outputs = { self, nixpkgs }:
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

    in
    {

      apps = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
            servescript = pkgs.writeShellScriptBin "serve" ''
              export CMD_DRAW_HEADTABLE="${self.packages.${system}.generate-headtable}/bin/generate-headtable"
              export CMD_DRAW_NUTRIENTS="${self.packages.${system}.generate-nutrients}/bin/generate-nutrients"
              export PATH=$PATH:${pkgs.mdbook-cmdrun}/bin
              echo "Using $CMD_DRAW_HEADTABLE and $CMD_DRAW_NUTRIENTS as generators"
              ${pkgs.mdbook}/bin/mdbook serve --open
            '';
          in
          {
            default = {
              type = "app";
              program = "${servescript}/bin/serve";
            };
          }
        );

      packages = forAllSystems
        (system:
          let
            pkgs = nixpkgsFor.${system};
          in
          {
            bash-example = pkgs.writeShellScriptBin "example-script" ''
              echo test
            '';

            book = pkgs.stdenv.mkDerivation {

              name = "book";
              src = ./.;
              buildPhase = null;

              CMD_DRAW_HEADTABLE = "${self.packages.${system}.generate-headtable}/bin/generate-headtable";
              CMD_DRAW_NUTRIENTS = "${self.packages.${system}.generate-nutrients}/bin/generate-nutrients";

              installPhase = ''
                runHook preInstall
                mdbook build -d $out
                runHook postInstall
              '';

              buildInputs = [ pkgs.mdbook pkgs.mdbook-cmdrun ];

              meta = with pkgs.lib; {
                homepage = "TODO";
                description = "TODO";
                license = licenses.mit;
                maintainers = [ maintainers.pinpox ];
              };

            };

            generate-headtable = pkgs.buildGoModule {
              pname = "generate-headtable";
              inherit version;
              src = ./helper-tools/generate-headtable;
              vendorHash = "sha256-g+yaVIx4jxpAQ/+WrGKxhVeliYx7nLQe/zsGpxV4Fn4=";
            };

            generate-nutrients = pkgs.buildGoModule {
              pname = "generate-nutrients";
              inherit version;
              src = ./helper-tools/generate-nutrients;
              vendorHash = "sha256-g+yaVIx4jxpAQ/+WrGKxhVeliYx7nLQe/zsGpxV4Fn4=";
            };
          });

      defaultPackage = forAllSystems (system: self.packages.${system}.book);
    };
}
