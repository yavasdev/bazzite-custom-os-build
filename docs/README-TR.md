# Custom Bazzite DX Nvidia (Tuxedo Edition) &nbsp; [![build badge](https://github.com/yavasdev/bazzite-custom-os-build/actions/workflows/build.yml/badge.svg)](https://github.com/yavasdev/bazzite-custom-os-build/actions/workflows/build.yml)

Bu depo, Abra A5 v16.6 (ve benzer donanımlar) için özel olarak hazırlanmış, [Bazzite DX Nvidia](https://github.com/ublue-os/bazzite) tabanlı bir **Atomic (Değişmez) Linux** işletim sistemi imajı üretir.

Orijinal Bazzite imajının üzerine aşağıdakiler sistem seviyesinde (natively) entegre edilmiştir:
- **Tuxedo Sürücüleri:** Güncel kernel modülleri kaynak koddan derlenerek sisteme gömülmüştür.
- **Tuxedo Control Center (TCC):** Donanım, fan ve güç yönetimi aracı.
- **Waydroid Helper & Android Tools:** Android uygulamalarını çalıştırmak için gerekli araçlar.

## Kurulum (Installation)

> [!WARNING]  
> Bu işlem mevcut Atomic Fedora / Bazzite işletim sisteminizin imajını değiştirecektir. İşletim sisteminizin Nvidia sürücülü bir versiyon olduğundan emin olun.

Mevcut işletim sisteminizi bu özel imaja geçirmek (rebase) için terminalde aşağıdaki adımları sırasıyla uygulayın:

**1. İmzasız İmaja Geçiş (İlk Kurulum):**
Gerekli güvenlik anahtarlarının ve kuralların sisteminize inmesi için önce imzasız (unverified) imaja geçiş yapın:
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/yavasdev/bazzite-dx-nvidia_with-tuxedo-drivers:latest
