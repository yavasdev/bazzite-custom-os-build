# ublue-tuxedo &nbsp; [![Build ublue-tuxedo Images](https://github.com/yavasdev/bazzite-tuxedo/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/yavasdev/bazzite-tuxedo/actions/workflows/build.yml)

[🇺🇸 English](README.md) | [🇹🇷 Türkçe](docs/README-TR.md)

Bu depo, uyumlu [Universal Blue](https://universal-blue.org/) taban imajları
için Tuxedo sürücüleri ve uygulamalarıyla donatılmış özel **Atomik
(Değişmez) Linux** işletim sistemi imajları oluşturur. Proje öncelikle TUXEDO
ve diğer Clevo dizüstü bilgisayarları hedefler; farklı Universal Blue imaj
aileleri ayrı tariflerle desteklenir.

Aşağıdaki özellikler, seçilen taban imajının üzerine entegre edilir:
- **Tuxedo Sürücüleri:** Kaynaktan derlenmiş ve doğrudan sisteme dahil edilmiş güncel çekirdek (kernel) modülleri.
- **Tuxedo Control Center (TCC):** Donanım, fan ve güç yönetimi aracı.

Tarifler, paket kurulumu için BlueBuild'in `dnf` modülünü kullanır. TCC,
imaj oluşturulurken indirilir; servis yönetimi yapan RPM kurulum script'leri
çalıştırılmadan açılır ve systemd unit dosyaları standart systemd dizinine
symlink olarak eklenir. Çekirdek modülleri eşleşen çekirdek geliştirme
dosyalarına karşı derlenir; base image depolarında uygun paket yoksa build
script'i çekirdeğin Fedora sürümünü dinamik olarak bulur ve tam eşleşen
`kernel-devel` paketini Fedora Koji'den indirir.

> [!WARNING]  
> Özel imajlar, Fedora projesinde [deneysel bir özelliktir](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), riski size ait olmak üzere deneyin.

## Kurulum

> [!WARNING]  
> Bu işlem, mevcut Atomik Fedora veya Universal Blue işletim sistemi imajınızı
değiştirecektir. Seçtiğiniz imaj varyantının donanımınız, taban imajınız ve
mevcut kurulumunuzla uyumlu olduğundan emin olun.

Yayımlanmış bir imaja geçmek için aşağıdaki komutlarda `<image>` yerine
kullanmak istediğiniz recipe tarafından oluşturulan imaj adını yazın:

- İmzalama anahtarlarını ve ilkelerini yüklemek için önce varsayılan imzasız imaja rebase edin:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/yavasdev/<image>:latest
  ```
- Rebase işlemini tamamlamak için yeniden başlatın:
  ```
  systemctl reboot
  ```
- Ardından imzalı imaja geçiş yapın:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/yavasdev/<image>:latest
  ```
- Kurulumu tamamlamak için tekrar yeniden başlatın:
  ```
  systemctl reboot
  ```

İmaj adları ve desteklenen varyantlar [`recipes/`](../recipes/) klasöründeki
dosyalarla belirlenir; bu örnek yalnızca Bazzite tabanlı imajlarla sınırlı
değildir. `latest` etiketi, yapılandırılan Fedora sürümü için en yeni imajı
gösterir. `stable` etiketi, bunu tanımlayan tariflerde yayımlanır.

## Recipe ve taban imaj notları

Bu, yalnızca Bazzite'e odaklanan bir depo değil, genel bir ublue-tuxedo
projesidir. Tarifler Bazzite, Bluefin, Aurora ve seçili Project Bluefin
imajları dahil olmak üzere birden fazla Universal Blue ailesini kapsar. Her
recipe taban imajı, paketleri, imaj adını ve desteklenen varyantı belirler.
Güncel ve yetkili liste [`recipes/`](../recipes/) klasöründedir.

Utah tarifleri, Utah'ın Hummingbird tabanlı çekirdeğini kullanır. Sabit bir
Fedora sürümüne veya genel bir `kernel-devel` paketine bağlı kalmak yerine,
build sırasında eşleşen çekirdek geliştirme dosyalarını dinamik olarak çözer.
Utah deneysel bir upstream olduğundan çekirdek ve paket kaynakları
değiştikçe ek uyumluluk çalışması gerekebilir.

Project Bluefin Dakota şu anda bu BlueBuild tarifleriyle uyumlu değildir.
Dakota, burada kullanılan DNF paket yönetimi yerine BuildStream ile oluşturulur.

## Doğrulama

Bu imajlar, [Sigstore](https://www.sigstore.dev/)'un [cosign](https://github.com/sigstore/cosign) aracı kullanılarak dijital olarak imzalanmıştır. İmajın orijinalliğini doğrulamak için bu depodan `cosign.pub` dosyasını indirebilir ve aşağıdaki komutu çalıştırabilirsiniz:

```bash
cosign verify --key cosign.pub ghcr.io/yavasdev/<image>:latest
```

---
---

## Ek Bilgi: ISO Oluşturma (Çevrimdışı Kurulum)

Eğer bu imajı bir USB sürücü kullanarak bir bilgisayara sıfırdan kurmak isterseniz, Fedora Atomik tabanlı bir sistemde kendi ISO dosyanızı oluşturabilirsiniz. Talimatlar için [BlueBuild ISO Rehberi](https://blue-build.org/how-to/generate-iso/#_top)'ne göz atın. *(ISO dosyaları çok büyük olduğundan GitHub üzerinde ücretsiz olarak barındırılamıyor ve ben de bununla uğraşmak istemiyorum).*
