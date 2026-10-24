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

## Human-tested distributions

The following table tracks variants that have been installed and used on
physical hardware. A successful CI build does not count as a human test.

| Distribution | Variant | Test status |
| --- | --- | --- |
| [Bazzite](https://bazzite.gg/) | Bazzite KDE | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite GNOME | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite NVIDIA | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite GNOME NVIDIA | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite DX KDE | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite DX GNOME | Not tested yet |
| [Bazzite](https://bazzite.gg/) | **Bazzite DX NVIDIA** | **Human tested** |
| [Bazzite](https://bazzite.gg/) | Bazzite DX GNOME NVIDIA | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite GDX KDE | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite Deck KDE | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite Deck GNOME | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite Deck NVIDIA | Not tested yet |
| [Bazzite](https://bazzite.gg/) | Bazzite Deck GNOME NVIDIA | Not tested yet |
| [Bluefin](https://projectbluefin.io/) | Bluefin | Not tested yet |
| [Bluefin](https://projectbluefin.io/) | Bluefin NVIDIA | Not tested yet |
| [Bluefin](https://projectbluefin.io/) | Bluefin DX | Not tested yet |
| [Bluefin](https://projectbluefin.io/) | Bluefin DX NVIDIA | Not tested yet |
| [Bluefin](https://projectbluefin.io/) | Bluefin Utah | Not tested yet |
| [Bluefin](https://projectbluefin.io/) | Bluefin Utah NVIDIA | Not tested yet |
| [Aurora](https://getaurora.dev/) | Aurora | Not tested yet |
| [Aurora](https://getaurora.dev/) | Aurora NVIDIA | Not tested yet |

Human-tested status depends on the specific laptop, GPU, kernel, and desktop
variant. Project Bluefin Dakota is excluded because it is not compatible with
the current BlueBuild recipes.

Want to help expand hardware coverage? If you can test one of the unverified
variants on your hardware, please [open an issue](https://github.com/yavasdev/ublue-tuxedo/issues)
with the image variant, laptop model, GPU, and your test results.


## Verification

These images are digitally signed using [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign) tool. To verify the authenticity of the image, you can download the `cosign.pub` file from this repository and run the following command:

```bash
cosign verify --key cosign.pub ghcr.io/yavasdev/<image>:latest
```

---
---

## Extra Information: ISO Generation (Offline Installation)

If you want to install this image from scratch on a computer using a USB drive, you can generate your own ISO file on a Fedora Atomic-based system. Check out the [BlueBuild ISO Guide](https://blue-build.org/how-to/generate-iso/#_top) for instructions. *(Since ISO files are very large, they cannot be hosted on GitHub for free and I don't want to bother it).*

## Potentially supported devices

These device families are potential candidates because they are TUXEDO
laptops or use Clevo chassis. This is not a compatibility guarantee: the exact
model, CPU/GPU configuration, firmware, and kernel all matter.

### TUXEDO laptops

- **InfinityBook:** InfinityBook Pro and InfinityBook Max families
- **Stellaris:** Stellaris 16 and other Stellaris configurations
- **Polaris:** Polaris 15/16 and other Polaris configurations
- **Sirius:** Sirius 16 and other Sirius configurations
- **Pulse:** Pulse 14/16 and other Pulse configurations
- **Aura:** Aura 14/15 and other Aura configurations

See the current [TUXEDO laptop lineup](https://www.tuxedocomputers.com/en/Linux-Hardware/Linux-Notebooks.tuxedo)
for exact models and configurations.

### Clevo-based laptops

Clevo laptops are sold under many different brands, so the Clevo chassis
identifier is often more useful than the retailer's model name. Potential
families include:

- **NH series:** NH50, NH55, NH57, NH58, NH70, NH77, and NH79
- **NS series:** NS50, NS51, NS70, and NS7x
- **P series:** P150, P151, P157, P170, and P7xx
- **V series:** V140, V150, V15x, and V17x

Known companies that have sold Clevo-based laptops, including historical or
model-specific offerings, include:

- **Turkey:** Monster Notebook
- **North America:** Sager, Eurocom, HIDevolution, Eluktronics, Origin PC,
  Xotic PC, Prostar, LPC Digital, Maingear, Digital Storm, and System76
- **United Kingdom and Ireland:** PCSpecialist and Scan
- **Germany and Central Europe:** Schenker/XMG, Medion, and PCW Polska
- **Benelux:** BTO, NovaCustom, Laptop With Linux, and Clevocenter
- **Portugal and Spain:** Obsidian-PC and Slimbook
- **Poland and Eastern Europe:** Dream Machines
- **Australia and New Zealand:** Metabox and Leader Computers
- **Singapore and Southeast Asia:** Aftershock and Illegear
- **Asia:** Thunderobot and other regional Clevo integrators and distributors

This is a broad, non-exhaustive list. Some companies use a mixture of Clevo,
Tongfang, Quanta, or proprietary chassis, and sourcing can change between
product generations. The exact model and chassis identifier must therefore
still be checked.

For Clevo devices, check the chassis identifier reported by the firmware or
`dmidecode` before opening a report. Please [open an issue](https://github.com/yavasdev/ublue-tuxedo/issues)
with the exact model, Clevo chassis identifier, CPU, GPU, and test results.
