# Vercel 배포 가이드

Flutter Todo 앱을 Vercel에 배포하는 방법입니다.

## 🚀 배포 방법

### 방법 1: Vercel CLI (추천)

#### 1단계: Vercel CLI 설치
```bash
npm install -g vercel
```

#### 2단계: 로컬에서 빌드
```bash
flutter build web --release
```

#### 3단계: Vercel 로그인
```bash
vercel login
```

#### 4단계: 배포
```bash
vercel --prod
```

빌드 디렉토리 선택: `build/web`

---

### 방법 2: Vercel Dashboard (더 쉬움!)

#### 1단계: GitHub에 푸시

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/todo-list.git
git push -u origin main
```

#### 2단계: Vercel에서 Import

1. [Vercel Dashboard](https://vercel.com) 접속
2. "Add New" → "Project" 클릭
3. GitHub 저장소 선택
4. 설정:
   ```
   Framework Preset: Other
   Build Command: flutter build web --release
   Output Directory: build/web
   Install Command: (비워두기)
   ```

#### 3단계: 환경 변수 설정

Vercel Dashboard → 프로젝트 → Settings → Environment Variables

추가할 변수:
```
SUPABASE_URL = https://your-project.supabase.co
SUPABASE_ANON_KEY = your-anon-key
```

#### 4단계: Deploy 클릭!

---

## ⚠️ 주의사항

### 1. Flutter가 Vercel에 기본 지원되지 않음

Vercel은 Flutter를 공식 지원하지 않지만, **정적 웹 빌드는 가능**합니다.

**해결:**
- 로컬에서 빌드 후 `build/web` 폴더만 배포
- 또는 GitHub Actions로 자동 빌드

### 2. 환경 변수 처리

**.env 파일은 빌드 시에만 사용됩니다!**

**중요:** Flutter 웹은 환경 변수를 런타임에 읽지 못합니다.

**해결 방법:**

#### 옵션 A: 빌드 시 환경 변수 주입
```bash
flutter build web --release --dart-define=SUPABASE_URL=https://...
```

#### 옵션 B: 환경별 별도 빌드

`.env.production` 생성:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-key
```

---

## 🎯 권장 배포 흐름

### GitHub Actions 자동 배포 (최고!)

`.github/workflows/deploy.yml` 생성:

```yaml
name: Deploy to Vercel

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.5'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Build web
        run: flutter build web --release
        
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: ./build/web
```

---

## 🔧 문제 해결

### 404 에러

**원인:**
- `build/web`가 아닌 프로젝트 루트를 배포
- SPA 라우팅 설정 안 됨

**해결:**
1. `vercel.json` 파일 확인
2. Output Directory: `build/web` 설정

### 빈 화면 / 로딩 무한

**원인:**
- 환경 변수 미설정
- Supabase 연결 실패

**해결:**
1. 브라우저 Console (F12) 확인
2. Vercel Dashboard → Environment Variables 설정
3. 재배포

### CORS 에러

**원인:**
- Supabase에서 Vercel 도메인 허용 안 됨

**해결:**
1. Supabase Dashboard → Settings → API
2. "Site URL" 및 "Redirect URLs"에 Vercel URL 추가:
   ```
   https://your-app.vercel.app
   ```

---

## 💡 더 쉬운 대안

### Netlify (Flutter 웹에 더 친화적!)

```bash
# 1. 빌드
flutter build web --release

# 2. Netlify에 드래그 앤 드롭
# build/web 폴더를 https://app.netlify.com/drop 에 드래그
```

### Firebase Hosting

```bash
# 1. Firebase CLI 설치
npm install -g firebase-tools

# 2. 로그인
firebase login

# 3. 초기화
firebase init hosting

# 4. 빌드
flutter build web --release

# 5. 배포
firebase deploy --only hosting
```

---

## 🎯 빠른 배포 (지금 당장!)

### 현재 상황에서 Vercel 배포:

#### 1. 로컬에서 빌드
```bash
flutter build web --release
```

#### 2. Vercel CLI로 배포
```bash
# Vercel CLI 설치 (처음만)
npm install -g vercel

# 배포
cd build/web
vercel --prod
```

#### 3. 환경 변수 설정
```bash
vercel env add SUPABASE_URL production
vercel env add SUPABASE_ANON_KEY production
```

#### 4. 재배포
```bash
vercel --prod
```

---

## ⚡ 제일 쉬운 방법

**Netlify Drop (드래그 앤 드롭):**

1. 터미널에서:
```bash
flutter build web --release
```

2. https://app.netlify.com/drop 접속
3. `build/web` 폴더를 드래그 앤 드롭
4. 완료! URL 받음!

---

## 📝 vercel.json 설정

프로젝트에 `vercel.json` 파일을 만들었습니다!

이 파일이 있으면 Vercel이 자동으로:
- Flutter 웹 빌드
- 올바른 폴더 배포
- SPA 라우팅 처리

---

지금 404가 뜬 이유는 아마도 빌드를 안 하고 배포하셨거나, 잘못된 폴더를 배포하신 것 같아요!

위의 방법대로 다시 시도해보세요! 어떤 방법으로 배포하시겠어요? 🚀
