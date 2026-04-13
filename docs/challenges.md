# Karşılaşılan Zorluklar

## 1. Immutable ECR ile `:latest` Çakışması

ECR repository'leri immutable tag ile kurulmuştu ama CI hâlâ `:latest` push ediyordu. Bu, `main` branch push'larında gereksiz hata üretiyordu.

Çözüm:

- CI push adımı sadece `${github.sha}` tag'i kullanacak şekilde düzeltildi
- CD deploy akışı runtime image set işlemini SHA üzerinden yapacak şekilde güncellendi

## 2. Deploy'ün Commit Edilmemiş Secret Dosyasına Bağlı Olması

CD workflow `k8s/mongodb/secret.yaml` uyguluyordu, ancak repoda sadece `.example` dosyası vardı.

Çözüm:

- Deploy sırasında `kubectl create secret generic ... --dry-run=client -o yaml | kubectl apply -f -` akışı eklendi
- Gerekli GitHub secret'ları açıkça belirlendi

## 3. EKS Dış Erişim Yolunun Eksik Olması

Manifestler ingress anlatıyordu ama repo içinde AWS Load Balancer Controller kurulumu yoktu. Bu nedenle dış erişim hikayesi eksikti.

Çözüm:

- Dış erişim `frontend` servisinin `LoadBalancer` olarak yayınlanmasına indirildi
- CD smoke testi load balancer hostname üstünden `/api/readyz/` çağıracak şekilde güncellendi
- NetworkPolicy bu yola göre hizalandı

## 4. Prometheus Konfigürasyonunun Gerçek Hedeflerle Uyuşmaması

Prometheus scrape ve alert kuralları olmayan target'lara ve üretilmeyen metriklere bağlıydı.

Çözüm:

- Backend'e gerçek `/metrics` endpoint'i eklendi
- Prometheus sadece `backend` ve kendisini scrape edecek şekilde sadeleştirildi
- Alert kuralları yalnızca gerçekten üretilen HTTP metriklerine bağlandı
- Alertmanager eklendi

## 5. Loki'nin Log Toplayıcı Olmadan Deploy Edilmesi

Tek başına Loki deploy etmek merkezi loglama sağlamıyordu.

Çözüm:

- Promtail DaemonSet eklendi
- Pod log'ları Loki'ye taşınacak şekilde RBAC ve scrape config tanımlandı
- Grafana dashboard'una log paneli eklendi

## 6. CI'da Anlamlı Test Eksikliği

Backend test script'i sahteydi ve repo gerçekten çalışan kullanıcı akışını doğrulamıyordu.

Çözüm:

- Backend için küçük ama gerçek unit testler eklendi
- Docker Compose tabanlı sağlık kontrolü CI'ya kondu
- Var olan Cypress akışı güncellenip create/delete smoke testine dönüştürüldü

## 7. Güvenlik İddiası ile Runtime Davranışının Uyuşmaması

Dokümanlar tüm container'ların non-root çalıştığını söylüyordu ama frontend `nginx:alpine` ile root başlıyordu.

Çözüm:

- Frontend `nginx-unprivileged` image'ına taşındı
- Konteyner portu 8080'e alındı
- Pod security context netleştirildi
