# Custom Bazzite DX Nvidia (Tuxedo Edition) &nbsp; [![build badge](https://github.com/yavasdev/bazzite-custom-os-build/actions/workflows/build.yml/badge.svg)](https://github.com/yavasdev/bazzite-custom-os-build/actions/workflows/build.yml)

[🇺🇸 English](README.md) | [🇹🇷 Türkçe](docs/README-TR.md)

This repository builds a custom **Atomic (Immutable) Linux** operating system image based on [Bazzite DX Nvidia](https://github.com/ublue-os/bazzite), specifically tailored for the Abra A5 v16.6 (and similar hardware).

The following features are integrated natively on top of the original Bazzite image:
- **Tuxedo Drivers:** Up-to-date kernel modules compiled from source and baked directly into the system.
- **Tuxedo Control Center (TCC):** Hardware, fan, and power management tool.
- **Waydroid Helper & Android Tools:** Essential tools required to run Android applications smoothly.

## Installation

> [!WARNING]  
> This process will replace your current Atomic Fedora / Bazzite operating system image. Make sure your current OS is an Nvidia variant before proceeding.

To rebase your existing operating system to this custom image, run the following commands in your terminal in order:

**1. Switch to the Unverified Image (Initial Setup):**
First, rebase to the unverified image to download the necessary security keys and policies to your system:
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/yavasdev/bazzite-dx-nvidia_with-tuxedo-drivers:latest
