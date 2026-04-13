# Ekran Görüntüleri

Bu klasör teslimat kanıtları için kullanılır.

Mevcut akış:

- Cypress smoke testi çalıştırıldığında `cypress/endToEnd.spec.js/app-home.png` ve `cypress/endToEnd.spec.js/record-list.png` burada üretilir

Cloud deploy tamamlandıktan sonra aşağıdaki ek görüntü de eklenmelidir:

- Tarayıcı adres çubuğunda dış load balancer hostname görünürken uygulama ana ekranı
- `kubectl get jobs -n baykar-app` çıktısı veya ETL smoke job log kanıtı

Önerilen son kontrol:

1. `make up`
2. `cd apps/frontend && npm ci && npx cypress run`
3. EKS deploy sonrası `kubectl create job --from=cronjob/etl etl-smoke-manual -n baykar-app` ile ETL'yi bir kez tetikle
4. Dış hostname ile manuel ekran görüntüsü ve ETL kanıtı ekle
