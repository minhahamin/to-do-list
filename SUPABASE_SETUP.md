# Supabase 설정 가이드

이 가이드를 따라 Supabase 프로젝트를 설정하고 Todo 앱과 연동하세요.

## 1. Supabase 프로젝트 생성

1. [Supabase](https://supabase.com) 접속
2. "Start your project" 클릭
3. GitHub 계정으로 로그인
4. "New project" 클릭
5. 프로젝트 정보 입력:
   - Name: `todo-list-app`
   - Database Password: 안전한 비밀번호 생성
   - Region: `Northeast Asia (Seoul)` 선택
6. "Create new project" 클릭

## 2. 데이터베이스 테이블 생성

### SQL Editor에서 실행

Supabase 대시보드에서 `SQL Editor`로 이동하여 다음 SQL을 실행하세요:

```sql
-- todos 테이블 생성
CREATE TABLE todos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  title TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  due_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  category TEXT DEFAULT 'other',
  notes TEXT,
  CONSTRAINT todos_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES auth.users(id) ON DELETE CASCADE
);

-- 인덱스 생성 (성능 향상)
CREATE INDEX todos_user_id_idx ON todos(user_id);
CREATE INDEX todos_created_at_idx ON todos(created_at);

-- Row Level Security (RLS) 활성화
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 사용자는 자신의 todos만 볼 수 있음
CREATE POLICY "Users can view their own todos"
  ON todos FOR SELECT
  USING (auth.uid() = user_id);

-- RLS 정책: 사용자는 자신의 todos만 삽입할 수 있음
CREATE POLICY "Users can insert their own todos"
  ON todos FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS 정책: 사용자는 자신의 todos만 업데이트할 수 있음
CREATE POLICY "Users can update their own todos"
  ON todos FOR UPDATE
  USING (auth.uid() = user_id);

-- RLS 정책: 사용자는 자신의 todos만 삭제할 수 있음
CREATE POLICY "Users can delete their own todos"
  ON todos FOR DELETE
  USING (auth.uid() = user_id);
```

## 3. 인증 설정

### 이메일 인증 활성화

1. Supabase 대시보드에서 `Authentication` > `Providers`로 이동
2. `Email` 활성화 (기본적으로 활성화되어 있음)

### Google 로그인 설정 (선택사항)

1. `Authentication` > `Providers` > `Google` 클릭
2. Google Cloud Console에서:
   - [Google Cloud Console](https://console.cloud.google.com) 접속
   - 새 프로젝트 생성
   - `APIs & Services` > `Credentials`
   - `Create Credentials` > `OAuth 2.0 Client ID`
   - Application type: `Web application`
   - Authorized redirect URIs에 Supabase 콜백 URL 추가:
     - `https://<your-project-ref>.supabase.co/auth/v1/callback`
   - Client ID와 Client Secret 복사
3. Supabase로 돌아와서:
   - Client ID와 Client Secret 입력
   - `Save` 클릭

## 4. Flutter 앱에 연동

### API 키 가져오기

1. Supabase 대시보드에서 `Settings` > `API`로 이동
2. 다음 값들을 복사:
   - `Project URL`
   - `anon public` key

### lib/main.dart 수정

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // Project URL로 교체
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // anon public key로 교체
);
```

## 5. 의존성 설치

터미널에서 다음 명령어 실행:

```bash
flutter pub get
```

## 6. 앱 실행

```bash
flutter run -d chrome
```

## 보안 주의사항

⚠️ **중요**: 
- `anon` key는 공개해도 안전합니다 (클라이언트 사이드용)
- `service_role` key는 절대 클라이언트에 노출하지 마세요
- Row Level Security (RLS)를 반드시 활성화하세요

## 테스트

1. 앱 실행 후 회원가입
2. 할 일 추가/수정/삭제 테스트
3. Supabase 대시보드의 `Table Editor`에서 데이터 확인
4. 다른 기기에서 같은 계정으로 로그인하여 동기화 확인

## 문제 해결

### 연결 오류
- URL과 anon key가 정확한지 확인
- 인터넷 연결 확인

### 권한 오류
- RLS 정책이 올바르게 설정되었는지 확인
- 사용자가 로그인되어 있는지 확인

### 동기화 안 됨
- 네트워크 연결 확인
- Supabase 대시보드에서 Realtime이 활성화되어 있는지 확인

## 무료 티어 제한

Supabase 무료 티어:
- 500MB 데이터베이스 공간
- 1GB 파일 저장공간
- 50,000 월간 활성 사용자
- 5GB 대역폭

개인 프로젝트에는 충분합니다!

## 다음 단계

- [ ] 실시간 동기화 구현
- [ ] 프로필 이미지 업로드
- [ ] 알림 기능 추가
- [ ] 할 일 공유 기능
