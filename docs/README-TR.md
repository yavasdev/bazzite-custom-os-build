# # uBlue Tuxedo — TUXEDO ve Clevo Dizüstü Bilgisayarları için Universal Blue İmajları 
[![Build ublue-tuxedo Images](https://github.com/yavasdev/ublue-tuxedo/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/yavasdev/ublue-tuxedo/actions/workflows/build.yml)

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

> [!WARNING]  
> Bu imajlar deneyseldir ve tamamen test edilmediler. Riski size ait olmak üzere deneyin.


### Mevcut Bazzite kullanıcıları

Mevcut Bazzite kurulumunuzdan rebase işlemine başlamadan önce upstream,
katmanlı paketleri kaldırmanızı önerir:

```bash
rpm-ostree reset
```

Donanımınızla uyumlu bir imaj seçin ve rebase sırasında mevcut kurulumunuzla aynı masaüstü ortamını koruyun. 

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

## İnsan tarafından test edilen dağıtımlar

Aşağıdaki tablo, fiziksel donanım üzerinde kurulup kullanılmış varyantları
gösterir. CI üzerinde başarılı bir derleme, insan tarafından test edilmiş
sayılmaz.

| Dağıtım | Varyant | Test durumu |
| --- | --- | --- |
| [Bazzite](https://bazzite.gg/) | Bazzite KDE | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite GNOME | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite NVIDIA | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite GNOME NVIDIA | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite DX KDE | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite DX GNOME | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | **Bazzite DX NVIDIA** | **İnsan tarafından test edildi** |
| [Bazzite](https://bazzite.gg/) | Bazzite DX GNOME NVIDIA | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite GDX KDE | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite Deck KDE | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite Deck GNOME | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite Deck NVIDIA | Henüz test edilmedi |
| [Bazzite](https://bazzite.gg/) | Bazzite Deck GNOME NVIDIA | Henüz test edilmedi |
| [Bluefin](https://projectbluefin.io/) | Bluefin | Henüz test edilmedi |
| [Bluefin](https://projectbluefin.io/) | Bluefin NVIDIA | Henüz test edilmedi |
| [Bluefin](https://projectbluefin.io/) | Bluefin DX | Henüz test edilmedi |
| [Bluefin](https://projectbluefin.io/) | Bluefin DX NVIDIA | Henüz test edilmedi |
| [Bluefin](https://projectbluefin.io/) | Bluefin Utah | Henüz test edilmedi |
| [Bluefin](https://projectbluefin.io/) | Bluefin Utah NVIDIA | Henüz test edilmedi |
| [Aurora](https://getaurora.dev/) | Aurora | Henüz test edilmedi |
| [Aurora](https://getaurora.dev/) | Aurora NVIDIA | Henüz test edilmedi |

İnsan tarafından test edilmiş olma durumu; belirli dizüstü bilgisayara, GPU'ya,
çekirdeğe ve masaüstü varyantına bağlıdır. Project Bluefin Dakota, mevcut
BlueBuild tarifleriyle uyumlu olmadığı için listeye dahil edilmemiştir.

Donanım kapsamını genişletmeye yardımcı olmak ister misiniz? Henüz
doğrulanmamış varyantlardan birini kendi donanımınızda test edebiliyorsanız,
lütfen imaj varyantını, dizüstü bilgisayar modelini, GPU'yu ve test sonuçlarınızı
belirterek [bir issue açın](https://github.com/yavasdev/ublue-tuxedo/issues).

## Doğrulama

Bu imajlar, [Sigstore](https://www.sigstore.dev/)'un [cosign](https://github.com/sigstore/cosign) aracı kullanılarak dijital olarak imzalanmıştır. İmajın orijinalliğini doğrulamak için bu depodan `cosign.pub` dosyasını indirebilir ve aşağıdaki komutu çalıştırabilirsiniz:

```bash
cosign verify --key cosign.pub ghcr.io/yavasdev/<image>:latest
```

---
---

## Ek Bilgi: ISO Oluşturma (Çevrimdışı Kurulum)

Eğer bu imajı bir USB sürücü kullanarak bir bilgisayara sıfırdan kurmak isterseniz, Fedora Atomik tabanlı bir sistemde kendi ISO dosyanızı oluşturabilirsiniz. Talimatlar için [BlueBuild ISO Rehberi](https://blue-build.org/how-to/generate-iso/#_top)'ne göz atın. *(ISO dosyaları çok büyük olduğundan GitHub üzerinde ücretsiz olarak barındırılamıyor ve ben de bununla uğraşmak istemiyorum).*

## Potansiyel olarak desteklenebilecek cihazlar

Bu cihaz aileleri TUXEDO dizüstü bilgisayarları olduğu veya Clevo kasalarını
kullandığı için potansiyel adaylardır. Bu bir uyumluluk garantisi değildir;
kesin model, CPU/GPU yapılandırması, firmware ve çekirdek sürümü önemlidir.

### TUXEDO dizüstü bilgisayarları

- **InfinityBook:** InfinityBook Pro ve InfinityBook Max aileleri
- **Stellaris:** Stellaris 16 ve diğer Stellaris yapılandırmaları
- **Polaris:** Polaris 15/16 ve diğer Polaris yapılandırmaları
- **Sirius:** Sirius 16 ve diğer Sirius yapılandırmaları
- **Pulse:** Pulse 14/16 ve diğer Pulse yapılandırmaları
- **Aura:** Aura 14/15 ve diğer Aura yapılandırmaları

Kesin model ve yapılandırmalar için güncel
[TUXEDO dizüstü bilgisayar listesine](https://www.tuxedocomputers.com/en/Linux-Hardware/Linux-Notebooks.tuxedo)
bakabilirsiniz.

### Clevo tabanlı dizüstü bilgisayarlar

Clevo dizüstü bilgisayarları farklı markalar altında satıldığından, satıcı
model adından ziyade Clevo kasa tanımlayıcısı daha kullanışlı olabilir.
Potansiyel aileler şunlardır:

- **NH serisi:** NH50, NH55, NH57, NH58, NH70, NH77 ve NH79
- **NS serisi:** NS50, NS51, NS70 ve NS7x
- **P serisi:** P150, P151, P157, P170 ve P7xx
- **V serisi:** V140, V150, V15x ve V17x

Clevo tabanlı dizüstü bilgisayarlar satan, geçmişte satmış olan veya belirli
modellerinde Clevo kullanan bilinen şirketler şunlardır:

- **Türkiye:** Monster Notebook
- **Kuzey Amerika:** Sager, Eurocom, HIDevolution, Eluktronics, Origin PC,
  Xotic PC, Prostar, LPC Digital, Maingear, Digital Storm ve System76
- **Birleşik Krallık ve İrlanda:** PCSpecialist ve Scan
- **Almanya ve Orta Avrupa:** Schenker/XMG, Medion ve PCW Polska
- **Benelüks:** BTO, NovaCustom, Laptop With Linux ve Clevocenter
- **Portekiz ve İspanya:** Obsidian-PC ve Slimbook
- **Polonya ve Doğu Avrupa:** Dream Machines
- **Avustralya ve Yeni Zelanda:** Metabox ve Leader Computers
- **Singapur ve Güneydoğu Asya:** Aftershock ve Illegear
- **Asya:** Thunderobot ve diğer bölgesel Clevo entegratörleri ve
  distribütörleri

Bu liste geniş ancak kapsamlı değildir. Bazı şirketler Clevo kasalarının yanı
sıra Tongfang, Quanta veya kendi tasarımları olan kasaları da kullanabilir;
kasa tedariki ürün nesilleri arasında değişebilir. Bu nedenle kesin model ve
kasa tanımlayıcısı yine de kontrol edilmelidir.

Clevo cihazlarda rapor açmadan önce firmware veya `dmidecode` ile kasa
tanımlayıcısını kontrol edin. Lütfen kesin model, Clevo kasa tanımlayıcısı,
CPU, GPU ve test sonuçlarıyla [bir issue açın](https://github.com/yavasdev/ublue-tuxedo/issues).
