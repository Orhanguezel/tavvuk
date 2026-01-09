Aşağıdaki “Studio Admin” template’i (frontend.zip) inceledim ve RTK Query ile Panel backend’ine **tek bir baseApi üzerinden** bağlamak için gerekli adımları, dosya/dizin bazında net bir plan halinde çıkardım.

## 1) Ekteki proje analizi (mevcut durum)

### Teknoloji / yapı

* Next.js **16.1.1**, App Router, TypeScript, Tailwind v4, shadcn/ui.
* Global layout `src/app/layout.tsx` **Server Component**; içeride `PreferencesStoreProvider` (Zustand) ile client-side preference yönetimi var.
* Auth ekranları var ama **şu an login formu sadece toast basıyor**; backend’e istek yok.
* Redux/RTK yok. Dependency’lerde `@tanstack/react-query` ve `axios` var ancak **src içinde kullanılmıyor** (en azından mevcut taramada).
* Dashboard sayfası “Coming Soon”; yani UI ekranlarını senin modüllere göre rahatça şekillendirebiliriz.

### Sonuç

Bu template, RTK Query entegre etmek için temiz; fakat:

* Redux store/provider katmanı eklenmeli,
* Login + session kontrolü (cookie tabanlı) backend’e bağlanmalı,
* Jobs/Servers/Projects/Nginx ekranları RTK Query endpoint’leri ile doldurulmalı.

---

## 2) Hedef mimari: “tek noktadan backend uçları”

Senin istediğin modele en uygun yapı:

* **Tek RTK baseApi**: `src/integrations/rtk/baseApi.ts`
* Tüm endpoint’ler burada inject edilir:

  * `authApi`, `jobsApi`, `serversApi`, `projectsApi`, `nginxApi`, (sonra `secretsApi`, `deployApi`)
* Tek bir “API URL” env üzerinden yönetilir:

  * `NEXT_PUBLIC_PANEL_API_URL=http://localhost:8078` (örnek)
* Cookie auth için `fetchBaseQuery` tarafında:

  * `credentials: "include"` zorunlu.

---

## 3) RTK ile çalıştırmak için gerekli adımlar (plan)

### Faz 0 — Kurulum ve temel iskelet

1. **Bağımlılıklar**

* `@reduxjs/toolkit`
* `react-redux`

2. **Redux store + RTK Query kur**

* `src/integrations/rtk/store.ts`
* `src/integrations/rtk/baseApi.ts`
* (opsiyonel) `src/integrations/rtk/listeners.ts` (refetchOnFocus vs)

3. **Provider ekle (kritik nokta)**
   Mevcut root layout server component olduğu için Redux Provider’ı bir **client wrapper** içine koyacağız.

* `src/app/providers.tsx` (use client)

  * `<Provider store={store}>`
  * İçeride mevcut `PreferencesStoreProvider`’ı da burada sarmalayabilirsin (tek noktaya toplanır).

* `src/app/layout.tsx`

  * `<Providers>{children}</Providers>` şeklinde güncelleme.

Bu adım bitince RTK Query hook’ları tüm uygulamada çalışır.

---

### Faz 1 — Ortak “API client” standardı (tek baseApi)

4. **baseApi standardı**

* `baseQuery: fetchBaseQuery({ baseUrl, credentials: "include", prepareHeaders })`
* `prepareHeaders`:

  * `x-locale` vb ileride gerekirse tek yerden eklersin.
  * `Authorization` gerekmeyecek (cookie kullanıyorsun), ama ileride token’a dönersen yine tek yerden.

5. **Tek noktadan endpoint injekte et**

* `src/integrations/rtk/endpoints/auth.endpoints.ts`
* `src/integrations/rtk/endpoints/jobs.endpoints.ts`
* `src/integrations/rtk/endpoints/servers.endpoints.ts`
* `src/integrations/rtk/endpoints/projects.endpoints.ts`
* `src/integrations/rtk/endpoints/nginx.endpoints.ts`

6. **Tipler**

* `src/integrations/types/*.types.ts` (DTO ve payload tipleri)

  * `JobDto`, `JobLogDto`, `ServerDto`, `ProjectDto`, `NginxPlanPayload`, `NginxApplyPayload` vb.

Bu fazın çıktısı: UI hiçbir yerinde “fetch/axios” yok; her şey RTK Query hook’larıyla gider.

---

### Faz 2 — Auth (cookie) entegrasyonu

7. **Login mutation**

* `POST /api/auth/login` (senin backend’de var)
* UI: `LoginForm` submit → `useLoginMutation` çağır
* Başarılıysa:

  * `router.push("/dashboard")`

8. **Session / Me endpoint**
   Template’te route-guard yok. Senin için iki seçenek:

* **Seçenek A (önerilen, basit):** Backend’e `GET /api/auth/me` ekle

  * UI her açılışta `useMeQuery` ile session kontrol eder
* **Seçenek B:** Mevcut bir “current user” endpoint’in varsa onu kullanırız.

9. **Route protection**

* `src/middleware.ts` ile `/dashboard`, `/jobs`, `/servers` gibi sayfaları koru.
* Middleware, `cookies()` ile session cookie var mı bakar; yoksa `/auth/v2/login` yönlendirir.

  * (Daha doğru kontrol için “me” çağrısı şart; ama middleware’de HTTP call istemezsen sadece cookie varlığıyla başlarız.)

---

### Faz 3 — Ops Console ekranları (RTK ile gerçek veri)

10. **Jobs ekranı**

* Liste: `GET /api/admin/jobs?status&type&serverId&projectId&limit&cursor`
* Detay: `GET /api/admin/jobs/:id`
* Log tail: `GET /api/admin/jobs/:id/logs?after&limit`
* UI’de polling:

  * list: 3–5sn
  * detail/log: 1–2sn

11. **Servers ekranı**

* CRUD list/detail
* `POST /api/admin/servers/:id/test` → job enqueue
* Son test job sonucu jobs ekranında görünür

12. **Projects ekranı**

* CRUD list/detail
* `PATCH /api/admin/projects/:id` ile `defaultServerId` set

13. **Nginx ekranı**

* `POST /api/admin/nginx/plan` → job
* `POST /api/admin/nginx/apply` → job
* Plan sonucu: job.result içinden diff viewer

Bu fazın çıktısı: “tek noktadan backend uçları çekme” tam olarak gerçekleşir.

---

## 4) Bu template üzerinde dikkat edilmesi gereken entegrasyon noktaları

* `src/app/layout.tsx` server component → Redux Provider doğrudan burada olmaz; **client Providers** şart.
* Template’in mevcut auth sayfaları “demo”; gerçek auth akışını RTK mutation + redirect ile kuracağız.
* Projede `react-query`/`axios` var ama kullanılmıyor; istersen bırakırız, istersen temizleriz (RTK ile gerekmeyecek).

---

## 5) Net yapılacaklar listesi (sıralı, minimum risk)

1. RTK paketleri ekle (`@reduxjs/toolkit`, `react-redux`)
2. `baseApi.ts + store.ts + Providers` kur, layout’a bağla
3. `auth.endpoints` yaz (login + me)
4. Login formunu RTK ile bağla
5. middleware ile sayfaları koru (ilk etap cookie varlığı)
6. Jobs endpoints + Jobs ekranı (liste + detail + logs)
7. Servers endpoints + servers ekranı (list + test)
8. Projects endpoints + projects ekranı (defaultServerId patch)
9. Nginx endpoints + nginx ekranı (plan/apply job izleme)

---

## 6) Dev ortamı için önerilen env

Frontend `.env.local`:

* `NEXT_PUBLIC_PANEL_API_URL=http://localhost:8078`

RTK baseApi:

* baseUrl: `${NEXT_PUBLIC_PANEL_API_URL}/api`

Cookie auth çalışması için backend CORS/credentials ayarlarını da doğrularız (frontend farklı origin’deyse şart).

---

İstersen bir sonraki adım olarak, bu planın **Faz 0–1** kısmını “patch set” şeklinde (dosya dosya) çıkarabilirim:

* `src/app/providers.tsx`
* `src/app/layout.tsx` güncellemesi
* `src/integrations/rtk/baseApi.ts`
* `src/integrations/rtk/store.ts`
* `auth.endpoints.ts` + hook export’ları
* Login formunun RTK ile bağlanmış hali

Böylece template ayağa kalkar ve Panel backend’e tek baseApi üzerinden bağlanmaya başlarız.
