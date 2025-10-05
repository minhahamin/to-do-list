# 🚀 Netlify 배포 가이드 (가장 쉬움!)

Flutter Todo 앱을 Netlify에 배포하는 방법입니다.

## ⭐ 방법 1: 드래그 앤 드롭 (5분!)

가장 쉽고 빠른 방법입니다!

### 1단계: 로컬에서 빌드
```bash
flutter build web --release
```

### 2단계: Netlify Drop 사이트 접속
https://app.netlify.com/drop

### 3단계: 드래그 앤 드롭
`build/web` 폴더를 웹사이트에 드래그!

### 4단계: 완료!
- 자동으로 URL 생성됨
- 예: https://amazing-app-123456.netlify.app

---

## 🔄 방법 2: GitHub 자동 배포 (권장!)

GitHub에 푸시하면 자동으로 배포됩니다.

### 1단계: netlify.toml 생성

프로젝트 루트에 파일 생성 (이미 생성됨):

```toml
[build]
  command = "flutter build web --release"
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### 2단계: GitHub에 푸시

```bash
git add .
git commit -m "Add Netlify config"
git push origin main
```

### 3단계: Netlify에서 Import

1. https://app.netlify.com 접속
2. "Add new site" → "Import an existing project"
3. GitHub 연결
4. 저장소 선택
5. 설정 확인:
   ```
   Build command: flutter build web --release
   Publish directory: build/web
   ```
6. "Deploy site" 클릭!

### 4단계: 환경 변수 설정

Netlify Dashboard → Site settings → Environment variables

추가:
```
SUPABASE_URL = https://your-project.supabase.co
SUPABASE_ANON_KEY = your-anon-key
```

---

## 🎯 방법 3: Netlify CLI

```bash
# 1. Netlify CLI 설치
npm install -g netlify-cli

# 2. 로그인
netlify login

# 3. 빌드
flutter build web --release

# 4. 배포
netlify deploy --prod --dir=build/web
```

---

## ✅ 장점

Netlify가 Flutter 웹에 최고인 이유:

- ✅ 드래그 앤 드롭만으로 배포
- ✅ Flutter 빌드 완벽 지원
- ✅ 무료 플랜: 월 100GB
- ✅ 자동 HTTPS
- ✅ 커스텀 도메인
- ✅ 빠른 CDN
- ✅ 환경 변수 쉬움

---

## 🔧 문제 해결

### 빌드 실패

**원인:** Flutter SDK 없음

**해결:** 로컬에서 빌드 후 배포
```bash
flutter build web --release
```

### 404 에러

**원인:** SPA 라우팅 설정 안 됨

**해결:** `netlify.toml`에 redirects 설정됨 (위 참고)

### 환경 변수 안 먹힘

**원인:** `.env` 파일은 빌드 시에만 작동

**해결:** 
1. 로컬에서 `.env` 설정 후 빌드
2. 빌드된 파일 배포

---

## 🎨 커스텀 도메인 설정

Netlify는 무료로 커스텀 도메인 가능!

1. 도메인 구매 (가비아, GoDaddy 등)
2. Netlify → Domain settings
3. DNS 설정 추가
4. 완료!

---

## 🚀 빠른 시작

### 지금 바로:

```bash
# 1. 빌드
flutter build web --release

# 2. https://app.netlify.com/drop 접속
# 3. build/web 드래그
# 4. 완료! 🎉
```

5분이면 됩니다!

---

## 💡 Vercel vs Netlify

| 기능 | Vercel | Netlify |
|------|--------|---------|
| Flutter 지원 | ⚠️ 수동 | ✅ 쉬움 |
| 드래그 배포 | ❌ | ✅ |
| 빌드 시간 | 느림 | 빠름 |
| 무료 플랜 | 100GB | 100GB |
| 설정 난이도 | 어려움 | 쉬움 |

**Flutter 웹 → Netlify 추천!**

---

## 📞 도움말

배포 중 문제가 생기면:
1. Netlify 로그 확인
2. 브라우저 Console (F12)
3. Supabase 연결 확인
