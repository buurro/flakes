{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }: {
    nixosConfigurations = {
      "some-berry" = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          ({ ... }: {
            networking.hostName = "some-berry";

            fileSystems."/" = {
              device = "/dev/disk/by-label/NIXOS_SD";
              fsType = "ext4";
            };
          })
          ./hosts/some-berry/configuration.nix
          nixos-hardware.nixosModules.raspberry-pi-4
        ];
      };
    };
    images = {
      "some-berry" = (
        self.nixosConfigurations."some-berry".extendModules {
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
          ];
        }
      ).config.system.build.sdImage;
    };
  };
}
