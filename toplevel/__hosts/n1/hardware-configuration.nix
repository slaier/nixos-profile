_:
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "usb_storage" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.kernelParams = [
    "iommu.passthrough=1"
  ];

  hardware.deviceTree = {
    enable = true;
    name = "amlogic/meson-gxl-s905d-phicomm-n1.dtb";
    kernelPackage = let kernel = config.boot.kernelPackages.kernel; in
      pkgs.stdenv.mkDerivation {
        name = "dtbs-with-symbols";
        inherit (kernel) src nativeBuildInputs depsBuildBuild;
        patches = (map (patch: patch.patch) kernel.kernelPatches) ++ [
          (pkgs.fetchpatch {
            name = "fix-dtb-of-aml-s905d-phicomm-n1.patch";
            url = "https://raw.githubusercontent.com/yunsur/phicomm-n1/d31bfec8707b5d6a43ef57d1473a887e54f0731a/patch/kernel/arm-64-legacy/fix-dtb-of-aml-s905d-phicomm-n1.patch";
            sha256 = "sha256-KuMYzwGE9bmIGigY/fSz1FPtC8MDnGrFdE+2si/pM1k=";
          })
        ];
        buildPhase = ''
          patchShebangs scripts/*
          substituteInPlace scripts/Makefile.lib \
            --replace 'DTC_FLAGS += $(DTC_FLAGS_$(basetarget))' 'DTC_FLAGS += $(DTC_FLAGS_$(basetarget)) -@'
          make ${pkgs.stdenv.hostPlatform.linux-kernel.baseConfig} ARCH="${pkgs.stdenv.hostPlatform.linuxArch}"
          make dtbs ARCH="${pkgs.stdenv.hostPlatform.linuxArch}"
        '';
        installPhase = ''
          make dtbs_install INSTALL_DTBS_PATH=$out/dtbs ARCH="${pkgs.stdenv.hostPlatform.linuxArch}"
        '';
      };
  };

  # I don't need wireless and bluetooth. Disable firmware to save disk space.
  hardware.firmware = lib.mkForce [ ];

  fileSystems."/" =
    {
      device = "/dev/mmcblk1p2";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/6454-42EE";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
