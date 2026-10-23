# Bazzite Linux Builds with Tuxedo Drivers and Apps
[![Build Bazzite Tuxedo Images](https://github.com/yavasdev/bazzite-tuxedo/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/yavasdev/bazzite-tuxedo/actions/workflows/build.yml)


[🇺🇸 English](README.md) | [🇹🇷 Türkçe](docs/README-TR.md) 

This repository builds custom **Atomic (Immutable) Linux** operating system images with Tuxedo drivers and apps on Bazzite DX ([GitHub](https://github.com/ublue-os/bazzite-dx) / [image](https://ghcr.io/ublue-os/bazzite-dx)), specifically tailored for Tuxedo or other Clevo laptops.

Available images:

- `ghcr.io/yavasdev/bazzite-tuxedo` (default Bazzite image)
- `ghcr.io/yavasdev/bazzite-dx-nvidia-tuxedo`
- `ghcr.io/yavasdev/bazzite-dx-tuxedo`

The following features are integrated natively on top of the original Bazzite image:
- **Tuxedo Drivers:** Up-to-date kernel modules compiled from source and baked directly into the system.
- **Tuxedo Control Center (TCC):** Hardware, fan, and power management tool.


> [!WARNING]  
> [Custom images are experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable) in fedora project, try at your own discretion.

## Installation

> [!WARNING]  
> This process will replace your current Atomic Fedora / Bazzite operating system image. Make sure that the image variant you choose matches your hardware and current installation.

> [!WARNING]  
> These images are experimental and have not been fully tested. Use them at your own discretion.

To rebase an existing Atomic Fedora installation to the default Bazzite Tuxedo image:

- First rebase to the unsigned image to install the signing keys and policies:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/yavasdev/bazzite-tuxedo:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then switch to the signed image:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/yavasdev/bazzite-tuxedo:latest
  ```
- Reboot again to complete the installation:
  ```
  systemctl reboot
  ```

For another variant, replace `bazzite-tuxedo` in the commands above with `bazzite-dx-nvidia-tuxedo` or `bazzite-dx-tuxedo`.

The `latest` tag points to the newest build for the configured Fedora version. The `stable` tag is also published by the recipes.


## Verification

These images are digitally signed using [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign) tool. To verify the authenticity of the image, you can download the `cosign.pub` file from this repository and run the following command:

```bash
cosign verify --key cosign.pub ghcr.io/yavasdev/bazzite-tuxedo:latest
```

---
---

## Extra Information: ISO Generation (Offline Installation)

If you want to install this image from scratch on a computer using a USB drive, you can generate your own ISO file on a Fedora Atomic-based system. Check out the [BlueBuild ISO Guide](https://blue-build.org/how-to/generate-iso/#_top) for instructions. *(Since ISO files are very large, they cannot be hosted on GitHub for free and I don't want to bother it).*
