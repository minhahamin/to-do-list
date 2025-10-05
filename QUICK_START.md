# 🚀 빠른 시작 가이드

할 일이 데이터베이스에 저장되도록 설정하기

## 1단계: Supabase 프로젝트 생성

1. https://supabase.com 접속
2. "Start your project" 클릭
3. GitHub 로그인
4. "New project" 클릭
5. 정보 입력:
   - Name: `todo-list-app`
   - Password: 안전한 비밀번호
   - Region: Seoul
6. "Create" 클릭 (1-2분 대기)

## 2단계: API 키 복사

1. 프로젝트 생성 완료 후
2. 좌측 메뉴: **Settings** → **API**
3. 복사:
   ```
   Project URL: https://xxxxx.supabase.co
   anon public: eyJhbGci...
   ```

## 3단계: .env 파일 설정

프로젝트 루트에 `.env` 파일 생성 (또는 수정):

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```

위에서 복사한 실제 값으로 교체!

## 4단계: 데이터베이스 테이블 생성

1. Supabase Dashboard → **SQL Editor**
2. 다음 SQL 복사 & 실행:

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
  notes TEXT
);

-- 인덱스
CREATE INDEX todos_user_id_idx ON todos(user_id);

-- RLS 활성화
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- 정책들
CREATE POLICY "Users can view their own todos"
  ON todos FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own todos"
  ON todos FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own todos"
  ON todos FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own todos"
  ON todos FOR DELETE USING (auth.uid() = user_id);
```

3. **Run** 버튼 클릭
4. **Table Editor** → `todos` 테이블 확인

## 5단계: 앱 재시작

```bash
# 앱 중지 (Ctrl+C)
flutter clean
flutter pub get
flutter run -d chrome
```

## 6단계: 테스트

1. 앱 실행
2. **이메일로 회원가입** (중요!)
3. 할 일 추가
4. Supabase Dashboard → **Table Editor** → `todos`
5. 새로고침 → 데이터 확인! 🎉

---

## ⚠️ 주의사항

### "로그인하지 않고 계속하기"를 누르면?
- ❌ 클라우드(DB)에 저장 안 됨
- ✅ 로컬에만 저장됨
- 💡 다른 기기에서 볼 수 없음

### DB에 저장하려면?
- ✅ 반드시 로그인 필요
- ✅ 이메일 회원가입 또는 구글 로그인

---

## 🔍 문제 해결

### 할 일이 DB에 안 들어가요

**체크리스트:**
- [ ] .env 파일에 실제 Supabase URL/Key 입력했나?
- [ ] todos 테이블 생성했나?
- [ ] RLS 정책 설정했나?
- [ ] 로그인했나? (로그인하지 않고 계속하기 ❌)
- [ ] 네트워크 연결되어 있나?

**확인 방법:**

1. **로그인 상태 확인**
   - 앱 우측 상단에 프로필 아이콘 있나?
   - 있으면 ✅ 로그인됨
   - 없으면 ⚠️ 로그인 필요

2. **네트워크 상태 확인**
   - 앱에서 구름 아이콘 ☁️이 있나?
   - 있으면 오프라인 상태

3. **테이블 확인**
   - Dashboard → Table Editor
   - `todos` 테이블이 있나?

4. **에러 확인**
   - 브라우저 Console (F12) 확인
   - 에러 메시지 있나?

### 자주 묻는 질문

**Q: 로그인 없이도 DB에 저장할 수 없나요?**
A: 보안상 불가능합니다. Supabase는 사용자 인증이 필요합니다.

**Q: 로컬 데이터를 DB로 옮기려면?**
A: 
1. 로그인
2. 계정 메뉴 → 백업 & 복원
3. JSON 가져오기

**Q: 다른 기기에서 보려면?**
A: 로그인한 상태에서만 가능합니다. 같은 계정으로 로그인하면 자동 동기화됩니다.

---

## ✅ 성공 확인

모든 설정이 완료되면:

1. 앱에서 할 일 추가
2. Dashboard → Table Editor → todos
3. 새로고침
4. 데이터가 보임! 🎉

```sql
-- SQL로 확인
SELECT * FROM todos;
```

---

## 🎯 다음 단계

- [ ] 프로필 이미지 추가
- [ ] 실시간 동기화 테스트
- [ ] 여러 기기에서 테스트
- [ ] 백업/복원 기능 사용
