# Bazzite DX Nvidia (Tuxedo Edition) &nbsp; 
[![bazzite-dx-nvidia](https://github.com/yavasdev/bazzite-dx-nvidia-tuxedo/actions/workflows/bazzite-dx-nvidia.yml/badge.svg?branch=main)](https://github.com/yavasdev/bazzite-dx-nvidia-tuxedo/actions/workflows/bazzite-dx-nvidia.yml)


[🇺🇸 English](README.md) | [🇹🇷 Türkçe](docs/README-TR.md) 

This repository builds a custom **Atomic (Immutable) Linux** operating system image based with tuxedo drivers and apps on Bazzite DX Nvidia ([github](https://github.com/ublue-os/bazzite-dx) / [image](https://ghcr.io/ublue-os/bazzite-dx-nvidia)), specifically tailored for Tuxedo or other Clevo laptops.

The following features are integrated natively on top of the original Bazzite image:
- **Tuxedo Drivers:** Up-to-date kernel modules compiled from source and baked directly into the system.
- **Tuxedo Control Center (TCC):** Hardware, fan, and power management tool.


> [!WARNING]  
> [Custom images are experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable) in fedora project, try at your own discretion.

## Installation

> [!WARNING]  
> This process will replace your current Atomic Fedora / Bazzite operating system image. Make sure your current OS is an Nvidia variant before proceeding.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/yavasdev/bazzite-dx-nvidia_with-tuxedo-drivers:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then switch to the Signed and Secure Image:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/yavasdev/bazzite-dx-nvidia_with-tuxedo-drivers:latest
  ```
- Reboot again to complete the installation:
  ```
  systemctl reboot
  ```

The `latest` tag will automatically pull the newest and most stable build for the Fedora version you have specified.


## Verification

These images are digitally signed using [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign) tool. To verify the authenticity of the image, you can download the `cosign.pub` file from this repository and run the following command:

```bash
cosign verify --key cosign.pub ghcr.io/yavasdev/bazzite-dx-nvidia_with-tuxedo-drivers
```

---
---

## Extra Information: ISO Generation (Offline Installation)

If you want to install this image from scratch on a computer using a USB drive, you can generate your own ISO file on a Fedora Atomic-based system. Check out the [BlueBuild ISO Guide](https://blue-build.org/how-to/generate-iso/#_top) for instructions. *(Since ISO files are very large, they cannot be hosted on GitHub for free and I don't want to bother it).*
