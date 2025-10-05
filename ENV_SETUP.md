# 환경 변수 설정 가이드

보안을 위해 환경 변수를 사용하여 민감한 정보를 관리합니다.

## 🔒 왜 필요한가요?

- ✅ API 키를 GitHub에 올리지 않음
- ✅ 개발/프로덕션 환경 분리
- ✅ 팀원마다 다른 설정 사용 가능
- ✅ 보안 강화

## 📝 설정 방법

### 1. .env 파일 생성

프로젝트 루트에 `.env` 파일이 이미 생성되어 있습니다.

### 2. Supabase 정보 입력

`.env` 파일을 열고 실제 값으로 교체하세요:

```env
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Supabase 키 가져오기

1. [Supabase Dashboard](https://app.supabase.com) 접속
2. 프로젝트 선택
3. 좌측 메뉴에서 `Settings` > `API` 클릭
4. 다음 값들을 복사:
   - **Project URL** → `SUPABASE_URL`
   - **anon public key** → `SUPABASE_ANON_KEY`

### 4. 패키지 설치

```bash
flutter pub get
```

### 5. 앱 실행

```bash
flutter run -d chrome
```

## ⚠️ 중요 사항

### .env 파일은 절대 Git에 올리지 마세요!

`.gitignore`에 이미 추가되어 있습니다:
```
.env
*.env
!.env.example
```

### 팀원과 공유할 때

1. `.env.example` 파일을 공유
2. 각자 `.env` 파일 생성
3. 실제 값 입력

## 🔍 확인 방법

앱 실행 시 다음과 같은 오류가 나오면 환경 변수 설정이 잘못된 것입니다:

```
Supabase client could not be initialized
```

### 해결 방법:

1. `.env` 파일이 프로젝트 루트에 있는지 확인
2. 파일 이름이 정확히 `.env`인지 확인 (공백 없음)
3. `SUPABASE_URL`과 `SUPABASE_ANON_KEY` 값이 올바른지 확인
4. 따옴표 없이 값을 입력했는지 확인

## 📱 다른 플랫폼 (Android/iOS)

### Android
- `android/app/build.gradle`에 추가 설정 필요 없음
- `.env` 파일이 자동으로 포함됨

### iOS
- `ios/Runner/Info.plist`에 추가 설정 필요 없음
- `.env` 파일이 자동으로 포함됨

## 🚀 프로덕션 배포

프로덕션 환경에서는:

1. `.env.production` 파일 생성
2. 프로덕션 Supabase 키 입력
3. 빌드 시 환경 지정:

```bash
flutter build web --dart-define=ENV=production
```

## 💡 추가 환경 변수 예시

`.env` 파일에 더 많은 설정을 추가할 수 있습니다:

```env
# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...

# 앱 설정
APP_NAME=Todo List Pro
APP_VERSION=1.0.0

# Firebase (나중에 추가 시)
FIREBASE_API_KEY=...
FIREBASE_PROJECT_ID=...

# Google Analytics (나중에 추가 시)
GA_TRACKING_ID=...
```

사용 예시:
```dart
final appName = dotenv.env['APP_NAME'];
final version = dotenv.env['APP_VERSION'];
```

## 🔧 문제 해결

### "Unable to load asset: .env"

**원인**: `.env` 파일이 없거나 `pubspec.yaml`에 등록되지 않음

**해결**:
1. `.env` 파일이 프로젝트 루트에 있는지 확인
2. `pubspec.yaml`의 `assets` 섹션 확인:
```yaml
flutter:
  assets:
    - .env
```
3. `flutter clean` 후 `flutter pub get` 실행

### 환경 변수가 null로 나옴

**원인**: 키 이름이 틀렸거나 값이 없음

**해결**:
1. `.env` 파일에서 키 이름 확인
2. 등호(=) 좌우에 공백이 없는지 확인
3. 값에 따옴표가 있으면 제거

### Hot Reload 시 환경 변수가 안 바뀜

**원인**: 환경 변수는 앱 시작 시 한 번만 로드됨

**해결**:
- `.env` 파일 수정 후 앱을 완전히 재시작 (Hot Restart: Shift + R)

## ✅ 체크리스트

설정 완료 확인:

- [ ] `.env` 파일 생성됨
- [ ] Supabase URL과 Key 입력됨
- [ ] `pubspec.yaml`에 `flutter_dotenv` 추가됨
- [ ] `assets`에 `.env` 등록됨
- [ ] `.gitignore`에 `.env` 추가됨
- [ ] `flutter pub get` 실행함
- [ ] 앱이 정상 실행됨
- [ ] 로그인이 작동함
