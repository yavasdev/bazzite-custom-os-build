# Bazzite DX Tuxedo İmajları &nbsp; [![Build Bazzite Tuxedo Images](https://github.com/yavasdev/bazzite-tuxedo/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/yavasdev/bazzite-tuxedo/actions/workflows/build.yml)

[🇺🇸 English](README.md) | [🇹🇷 Türkçe](docs/README-TR.md)

Bu depo, özellikle Tuxedo veya diğer Clevo dizüstü bilgisayarlar için uyarlanmış, Bazzite DX ([GitHub](https://github.com/ublue-os/bazzite-dx) / [imaj](https://ghcr.io/ublue-os/bazzite-dx)) temel alınarak Tuxedo sürücüleri ve uygulamalarıyla donatılmış özel **Atomik (Değişmez) Linux** işletim sistemi imajları oluşturur.

Kullanılabilir imajlar:

- `ghcr.io/yavasdev/bazzite-tuxedo` (varsayılan Bazzite imajı)
- `ghcr.io/yavasdev/bazzite-dx-nvidia-tuxedo`
- `ghcr.io/yavasdev/bazzite-dx-tuxedo`

Aşağıdaki özellikler, orijinal Bazzite imajının üzerine doğrudan entegre edilmiştir:
- **Tuxedo Sürücüleri:** Kaynaktan derlenmiş ve doğrudan sisteme dahil edilmiş güncel çekirdek (kernel) modülleri.
- **Tuxedo Control Center (TCC):** Donanım, fan ve güç yönetimi aracı.

> [!WARNING]  
> Özel imajlar, Fedora projesinde [deneysel bir özelliktir](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), riski size ait olmak üzere deneyin.

## Kurulum

> [!WARNING]  
> Bu işlem, mevcut Atomik Fedora / Bazzite işletim sistemi imajınızı değiştirecektir. Seçtiğiniz imaj varyantının donanımınız ve mevcut kurulumunuzla uyumlu olduğundan emin olun.

Varsayılan Bazzite Tuxedo imajını mevcut bir Atomik Fedora kurulumuna rebase etmek (yeniden temellendirmek) için:

- İmzalama anahtarlarını ve ilkelerini yüklemek için önce varsayılan imzasız imaja rebase edin:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/yavasdev/bazzite-tuxedo:latest
  ```
- Rebase işlemini tamamlamak için yeniden başlatın:
  ```
  systemctl reboot
  ```
- Ardından imzalı imaja geçiş yapın:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/yavasdev/bazzite-tuxedo:latest
  ```
- Kurulumu tamamlamak için tekrar yeniden başlatın:
  ```
  systemctl reboot
  ```

Başka bir varyant için yukarıdaki komutlarda `bazzite-tuxedo` yerine `bazzite-dx-nvidia-tuxedo` veya `bazzite-dx-tuxedo` kullanın.

`latest` etiketi, yapılandırılan Fedora sürümü için en yeni imajı gösterir. Tariflerde ayrıca `stable` etiketi de yayımlanır.

## Doğrulama

Bu imajlar, [Sigstore](https://www.sigstore.dev/)'un [cosign](https://github.com/sigstore/cosign) aracı kullanılarak dijital olarak imzalanmıştır. İmajın orijinalliğini doğrulamak için bu depodan `cosign.pub` dosyasını indirebilir ve aşağıdaki komutu çalıştırabilirsiniz:

```bash
cosign verify --key cosign.pub ghcr.io/yavasdev/bazzite-tuxedo:latest
```

---
---

## Ek Bilgi: ISO Oluşturma (Çevrimdışı Kurulum)

Eğer bu imajı bir USB sürücü kullanarak bir bilgisayara sıfırdan kurmak isterseniz, Fedora Atomik tabanlı bir sistemde kendi ISO dosyanızı oluşturabilirsiniz. Talimatlar için [BlueBuild ISO Rehberi](https://blue-build.org/how-to/generate-iso/#_top)'ne göz atın. *(ISO dosyaları çok büyük olduğundan GitHub üzerinde ücretsiz olarak barındırılamıyor ve ben de bununla uğraşmak istemiyorum).*
