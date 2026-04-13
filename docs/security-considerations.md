# Güvenlik Değerlendirmesi

## Bu Repoda Gerçekten Uygulananlar

### Container Seviyesi

- Frontend `nginx-unprivileged` image'ı ile non-root çalışır
- Backend container `node` kullanıcısıyla ve `runAsNonRoot` ile çalışır
- Frontend ve backend pod'larında `allowPrivilegeEscalation: false` ayarlıdır
- Frontend multi-stage build kullanır

### Secret Yönetimi

- MongoDB credential'ları repoya commit edilmez
- Alertmanager webhook URL'i repo yerine secret olarak sağlanır
- `k8s/mongodb/secret.yaml.example` sadece örnek dosyadır
- CD workflow secret manifest beklemez; deploy anında K8s secret üretir

### Ağ Güvenliği

- MongoDB dış dünyaya açık değildir
- Backend sadece frontend ve monitoring namespace'inden gelen trafiği kabul eder
- Default deny ingress policy vardır

### CI/CD Güvenliği

- AWS erişimi repo-scoped GitHub OIDC role assumption ile yapılır
- Aynı rol için EKS access entry tanımlanarak `kubectl` yetkisi statik kullanıcıya ihtiyaç duymadan verilir
- ECR repository'leri immutable tag kullanır
- CI yalnızca commit SHA tag'leri push eder

## Bilinçli Olarak Uygulanmayanlar

Bu repo production-hardening örneği değil, teslim edilebilir case çalışmasıdır. Aşağıdakiler dokümante edilmiştir ama uygulanmamıştır:

- TLS / HTTPS sonlandırma
- External secrets manager entegrasyonu
- Pod security admission politikaları
- Backup ve restore otomasyonu
- WAF ve mTLS

## Kalan Riskler

- Frontend servisi internet'e açık olduğu için TLS eklenmeden gerçek kullanıcı trafiği için uygun değildir
- MongoDB tek replika olduğu için node kaybında servis kesintisi yaşanabilir
- Monitoring bileşenleri `emptyDir` kullandığı için pod yeniden başlarsa veri kaybı olur

## Teslimat Öncesi Kontrol Listesi

- [x] Non-root runtime claim'i doğru
- [x] Git'e gerçek secret commit edilmiyor
- [x] CD secret manifest'e bağlı değil
- [x] Image tag stratejisi immutable
- [ ] TLS aktif
- [ ] Backup/restore akışı test edilmiş
