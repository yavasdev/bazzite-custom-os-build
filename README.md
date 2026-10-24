# uBlue Tuxedo — Universal Blue Images for TUXEDO and Clevo Laptops
[![Build ublue-tuxedo Images](https://github.com/yavasdev/ublue-tuxedo/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/yavasdev/ublue-tuxedo/actions/workflows/build.yml)


[🇺🇸 English](README.md) | [🇹🇷 Türkçe](docs/README-TR.md) 

This repository builds custom **Atomic (Immutable) Linux** operating system images with Tuxedo drivers and applications for compatible [Universal Blue](https://universal-blue.org/) base images. It is intended primarily for TUXEDO and other Clevo laptops, while supporting multiple Universal Blue image families through separate recipes.

The recipes integrate the following features on top of their selected base image:
- **Tuxedo Drivers:** Up-to-date kernel modules compiled from source and baked directly into the system.
- **Tuxedo Control Center (TCC):** Hardware, fan, and power management tool.

The recipes use BlueBuild's `dnf` module for package installation. TCC is
downloaded during the image build, unpacked without running service-management
scripts, and its systemd units are linked into the standard systemd directory.
Kernel modules are compiled against the matching kernel development tree; when
the base repositories do not provide it, the build resolves the kernel's Fedora
release and downloads the exact `kernel-devel` package from Fedora Koji.


> [!WARNING]  
> [Custom images are experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable) in fedora project, try at your own discretion.

## Installation

> [!WARNING]  
> This process will replace your current Atomic Fedora or Universal Blue operating system image. Make sure that the image variant you choose matches your hardware, base image, and current installation.

> [!WARNING]  
> These images are experimental and have not been fully tested. Use them at your own discretion.

### Existing Bazzite users

Before rebasing from an existing Bazzite installation, upstream recommends
removing layered packages:

```bash
rpm-ostree reset
```

Choose an image that matches your hardware and keep the same desktop environment as your current installation when rebasing.

To rebase an existing Atomic Fedora installation to a published image, replace
`<image>` with the name of the recipe-built image you want to use:

- First rebase to the unsigned image to install the signing keys and policies:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/yavasdev/<image>:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then switch to the signed image:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/yavasdev/<image>:latest
  ```
- Reboot again to complete the installation:
  ```
  systemctl reboot
  ```

Image names and supported variants are defined by the files in [`recipes/`](recipes/);
the example above is not limited to Bazzite-based images. The `latest` tag points
to the newest build for the configured Fedora version. The `stable` tag is also
published by recipes that define it.

## Recipe and base image notes

This is a general ublue-tuxedo repository rather than a Bazzite-only project.
Recipes cover multiple Universal Blue families, including Bazzite, Bluefin,
Aurora, and selected Project Bluefin images. Each recipe determines its base
image, packages, image name, and supported variant. The authoritative list is
the [`recipes/`](recipes/) directory.

The Utah recipes use Utah's Hummingbird-based kernel. They resolve matching
kernel development files dynamically during the build instead of relying on a
fixed Fedora release or a generic `kernel-devel` package. Utah is experimental
and may require additional compatibility work as its kernel and package
sources change.

Project Bluefin Dakota is not currently compatible with these BlueBuild
recipes. Dakota is assembled with BuildStream rather than the DNF
package-management model used here.


## Verification

These images are digitally signed using [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign) tool. To verify the authenticity of the image, you can download the `cosign.pub` file from this repository and run the following command:

```bash
cosign verify --key cosign.pub ghcr.io/yavasdev/<image>:latest
```

---
---

## Extra Information: ISO Generation (Offline Installation)

If you want to install this image from scratch on a computer using a USB drive, you can generate your own ISO file on a Fedora Atomic-based system. Check out the [BlueBuild ISO Guide](https://blue-build.org/how-to/generate-iso/#_top) for instructions. *(Since ISO files are very large, they cannot be hosted on GitHub for free and I don't want to bother it).*
