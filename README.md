# Nile Storefront

واجهة متجر Nile Market. تُبنى كصورة Docker غير root، وتمر عبر بوابة إصدار آلية قبل أي نشر.

## التشغيل المحلي
```bash
docker build --build-arg APP_VERSION=local-dev -t nile-storefront:local-dev .
IMAGE=nile-storefront:local-dev EXPECTED_VERSION=local-dev bash scripts/smoke-test.sh
```

## الاختبار اليدوي بعد التشغيل
```bash
docker run -d -p 8080:8080 --name storefront nile-storefront:local-dev
curl http://127.0.0.1:8080/healthz
```

## الخطوات القادمة
- [x] Sprint 7 - اليوم 4: بناء، فحص، اختبار دخان
- [ ] NM-219: النشر إلى GHCR بعد اجتياز البوابة على `main`