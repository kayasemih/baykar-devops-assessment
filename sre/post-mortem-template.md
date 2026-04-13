# Post-Mortem Template — Olay Sonrası Analiz Şablonu

Bu şablon, ciddi olaylar (P1/P2) sonrasında blameless (suçlama yapmayan) bir kök neden analizi yürütmek için kullanılır.

---

## Olay Bilgileri

| Alan | Değer |
|------|-------|
| **Olay Başlığı** | [Kısa ve açıklayıcı bir başlık] |
| **Tarih** | YYYY-MM-DD |
| **Severity** | P1 / P2 |
| **Süre** | Başlangıç: HH:MM — Bitiş: HH:MM (toplam: X dakika) |
| **Etkilenen Servisler** | [frontend / backend / mongodb / etl] |
| **Müdahale Eden** | [İsimler] |
| **Yazan** | [İsim] |

---

## Özet

[2-3 cümle ile ne oldu, ne kadar sürdü, etkisi ne oldu]

---

## Etki Analizi

- **Kullanıcı Etkisi:** [Kaç kullanıcı etkilendi? Ne yapamadılar?]
- **İş Etkisi:** [Veri kaybı var mı? Gelir etkisi var mı?]
- **SLO Etkisi:** [Error budget'tan ne kadar harcandı?]

---

## Zaman Çizelgesi

| Zaman (UTC) | Olay |
|-------------|------|
| HH:MM | [Sorun başladı / ilk belirtiler] |
| HH:MM | [Alert tetiklendi] |
| HH:MM | [On-call mühendis acknowledge etti] |
| HH:MM | [İlk tanı koyuldu] |
| HH:MM | [Mitigation uygulandı] |
| HH:MM | [Servis normale döndü] |
| HH:MM | [Kalıcı çözüm uygulandı] |

---

## Kök Neden

**Doğrudan neden:** [Ne hata yaptı?]

**Altta yatan neden:** [Neden bu hata oluşabildi? Hangi koruma eksikti?]

**Tetikleyici:** [Ne tetikledi? Deployment? Trafik artışı? Konfigürasyon değişikliği?]

---

## Neler İyi Gitti

- [Aktif izleme sayesinde erken fark edildi]
- [Runbook doğru adımları içeriyordu]
- [Rollback hızlı çalıştı]
- [Ekip iletişimi etkindi]

---

## Neler Kötü Gitti

- [Alert geç tetiklendi]
- [Runbook bu senaryoyu kapsamıyordu]
- [Rollback mekanizması test edilmemişti]
- [Yedek sistem devreye girmedi]

---

## Nerede Şanslıydık

- [Düşük trafik saatinde oldu]
- [Backup'lar günceldi]
- [İlgili mühendis online'dı]

---

## Aksiyon Maddeleri

| # | Aksiyon | Öncelik | Atanan | Hedef Tarih | Durum |
|---|---------|---------|--------|-------------|-------|
| 1 | [Alert eşiğini düşür] | Yüksek | [İsim] | YYYY-MM-DD | ☐ |
| 2 | [Runbook'a yeni senaryo ekle] | Orta | [İsim] | YYYY-MM-DD | ☐ |
| 3 | [Otomatik rollback mekanizması ekle] | Yüksek | [İsim] | YYYY-MM-DD | ☐ |
| 4 | [Chaos testi planla] | Düşük | [İsim] | YYYY-MM-DD | ☐ |

---

## Dersler

[Bu olaydan ne öğrendik? Benzer olayları nasıl önleyebiliriz? Sistemik bir sorun var mı?]

---

> **Hatırlatma:** Post-mortem'ler blameless (suçlama yapmayan) olmalıdır.
> Amaç kişileri suçlamak değil, sistemleri iyileştirmektir.
> "Kim hata yaptı?" yerine "Sistem neden bu hatanın oluşmasına izin verdi?" sorusunu sorarız.
