# Bazzite DX Nvidia (Tuxedo Edition) &nbsp; [![build badge](https://github.com/yavasdev/bazzite-custom-os-build/actions/workflows/build.yml/badge.svg)](https://github.com/yavasdev/bazzite-custom-os-build/actions/workflows/build.yml)

[🇺🇸 English](README.md) | [🇹🇷 Türkçe](docs/README-TR.md)

Bu depo, özellikle Tuxedo veya diğer Clevo dizüstü bilgisayarlar için uyarlanmış, Bazzite DX Nvidia ([github](https://github.com/ublue-os/bazzite-dx) / [imaj](https://ghcr.io/ublue-os/bazzite-dx-nvidia)) temel alınarak tuxedo sürücüleri ve uygulamalarıyla donatılmış özel bir **Atomik (Değişmez) Linux** işletim sistemi imajı oluşturur.

Aşağıdaki özellikler, orijinal Bazzite imajının üzerine doğrudan entegre edilmiştir:
- **Tuxedo Sürücüleri:** Kaynaktan derlenmiş ve doğrudan sisteme dahil edilmiş güncel çekirdek (kernel) modülleri.
- **Tuxedo Control Center (TCC):** Donanım, fan ve güç yönetimi aracı.

> [!WARNING]  
> Özel imajlar, Fedora projesinde [deneysel bir özelliktir](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), riski size ait olmak üzere deneyin.

## Kurulum

> [!WARNING]  
> Bu işlem, mevcut Atomik Fedora / Bazzite işletim sistemi imajınızı değiştirecektir. Devam etmeden önce mevcut işletim sisteminizin bir Nvidia varyantı olduğundan emin olun.

Mevcut bir atomik Fedora kurulumunu en son sürüme rebase etmek (yeniden temellendirmek) için:

- Gerekli imzalama anahtarlarının ve ilkelerinin yüklenmesi için öncelikle imzasız imaja rebase edin:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/yavasdev/bazzite-dx-nvidia_with-tuxedo-drivers:latest
  ```
- Rebase işlemini tamamlamak için yeniden başlatın:
  ```
  systemctl reboot
  ```
- Ardından İmzalı ve Güvenli İmaja geçiş yapın:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/yavasdev/bazzite-dx-nvidia_with-tuxedo-drivers:latest
  ```
- Kurulumu tamamlamak için tekrar yeniden başlatın:
  ```
  systemctl reboot
  ```

`latest` etiketi, belirttiğiniz Fedora sürümü için en yeni ve en kararlı yapıyı otomatik olarak çekecektir.

## Doğrulama

Bu imajlar, [Sigstore](https://www.sigstore.dev/)'un [cosign](https://github.com/sigstore/cosign) aracı kullanılarak dijital olarak imzalanmıştır. İmajın orijinalliğini doğrulamak için bu depodan `cosign.pub` dosyasını indirebilir ve aşağıdaki komutu çalıştırabilirsiniz:

```bash
cosign verify --key cosign.pub ghcr.io/yavasdev/bazzite-dx-nvidia_with-tuxedo-drivers
```

---
---

## Ek Bilgi: ISO Oluşturma (Çevrimdışı Kurulum)

Eğer bu imajı bir USB sürücü kullanarak bir bilgisayara sıfırdan kurmak isterseniz, Fedora Atomik tabanlı bir sistemde kendi ISO dosyanızı oluşturabilirsiniz. Talimatlar için [BlueBuild ISO Rehberi](https://blue-build.org/how-to/generate-iso/#_top)'ne göz atın. *(ISO dosyaları çok büyük olduğundan GitHub üzerinde ücretsiz olarak barındırılamıyor ve ben de bununla uğraşmak istemiyorum).*
