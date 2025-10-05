# Todo List Pro 🎯

Flutter + Supabase(PostgreSQL)로 만든 프로페셔널 할 일 관리 앱

- 배포 : https://jocular-otter-c09800.netlify.app/

**포트폴리오 프로젝트** | **풀스택 웹 앱** | **실시간 클라우드 동기화**

---

## ✨ 주요 기능

### 📝 기본 기능
- ✅ 할 일 추가/수정/삭제
- ✅ 완료 상태 체크/해제
- ✅ 스와이프하여 삭제
- ✅ 드래그 앤 드롭으로 순서 변경

### 🎯 고급 할 일 관리
- 📅 **마감일 설정** - 오늘/지연 시각적 표시
- 🔄 **반복 일정** - 매일/매주/매달/매년 자동 반복
- 🏷️ **카테고리 분류** - 공부, 운동, 프로젝트, 업무, 개인, 기타
- 🚩 **우선순위** - 낮음/보통/높음
- 📝 **상세 메모** - 할 일에 상세 설명 추가
- 🔗 **링크 첨부** - 관련 URL 여러 개 첨부
- ✅ **서브태스크** - 체크리스트로 세부 작업 관리
- 📊 **진행률 바** - 서브태스크 완료 현황 시각화

### 🧠 AI 기능
- 🤖 **자동 카테고리 분류** - "회의" → 업무, "숙제" → 공부
- 🎯 **우선순위 제안** - 마감일 기반 자동 우선순위
- 🎤 **음성 인식** - 말로 할 일 추가 (Chrome 지원)

### 🎨 UX/UI
- 🔍 **실시간 검색** - 제목, 카테고리, 메모 검색
- 🔄 **다양한 정렬** - 날짜순, 마감일순, 카테고리순, 완료순
- 🏷️ **카테고리 필터** - 원하는 카테고리만 보기
- 🌙 **다크모드** - 눈에 편한 어두운 테마
- 📊 **실시간 통계** - 완료율, 오늘 마감, 지연된 할 일

### ☁️ 클라우드 & 데이터
- 🔐 **이메일 인증** - 안전한 로그인/회원가입
- 🔄 **자동 동기화** - 여러 기기에서 실시간 동기화
- 💾 **오프라인 지원** - 인터넷 없이도 작동
- 🍪 **세션 유지** - 새로고침해도 로그인 유지
- 📤 **백업/복원** - JSON 파일로 내보내기/가져오기
- 🔄 **수동 동기화** - 원할 때 클라우드와 동기화
- 🗄️ **PostgreSQL** - 강력한 관계형 데이터베이스

### 📈 통계 & 분석
- 📊 **주간 완료율 그래프** - 꺾은선 차트로 생산성 시각화
- 📈 **카테고리별 분포** - 어떤 일을 많이 하는지 확인
- 🎯 **완료율 추적** - 전체/주간 완료율 분석
- ⏰ **오늘 마감 현황** - 오늘 해야 할 일 카운트
- ⚠️ **지연 알림** - 지연된 할 일 시각적 표시

---

## 🖼️ 스크린샷

### 메인 화면
- 그라데이션 헤더 (보라색 → 핑크)
- 진행률 통계 카드 3개
- 카테고리 필터 칩
- 할 일 카드 (우선순위별 색상)

### 할 일 추가 화면
- AI 자동 분류 토글
- 우선순위 선택
- 카테고리 선택
- 마감일 & 반복 설정
- 메모 입력
- 링크 추가
- 서브태스크 추가

### 통계 화면
- 주간 완료율 그래프
- 카테고리별 통계
- 생산성 분석

---

## 🚀 시작하기

### 필수 요구사항

- **Flutter SDK** 3.0.0 이상
- **Dart SDK** 3.0.0 이상
- **Supabase 계정** (무료)

### 설치 단계

#### 1. 프로젝트 클론
```bash
git clone <repository-url>
cd to-do-list
```

#### 2. 의존성 설치
```bash
flutter pub get
```

#### 3. Supabase 프로젝트 설정

**자세한 내용은 [SUPABASE_SETUP.md](SUPABASE_SETUP.md) 참고**

1. [Supabase](https://supabase.com) 가입
2. 새 프로젝트 생성
3. SQL Editor에서 테이블 생성:

```sql
-- DATABASE_UPDATE.sql 파일 참고
-- todos 테이블 생성 + 컬럼 추가
```

#### 4. 환경 변수 설정

**자세한 내용은 [ENV_SETUP.md](ENV_SETUP.md) 참고**

프로젝트 루트에 `.env` 파일 생성:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

#### 5. 앱 실행
```bash
# 웹 (Chrome 권장)
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows 데스크톱
flutter run -d windows
```

---

## 📁 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점, 테마 관리
├── models/
│   ├── todo_item.dart          # Todo 데이터 모델, AI 분류
│   └── user_profile.dart       # 사용자 프로필 모델
├── screens/
│   ├── todo_list_screen.dart   # 메인 화면
│   └── auth_screen.dart        # 로그인/회원가입
├── widgets/
│   ├── stat_card.dart          # 통계 카드 위젯
│   ├── category_chip.dart      # 카테고리 필터 칩
│   ├── todo_card.dart          # 할 일 카드 위젯
│   ├── voice_input_button.dart # 음성 인식 버튼
│   └── statistics_chart.dart   # 주간 통계 그래프
├── dialogs/
│   ├── todo_dialog.dart        # 할 일 추가/수정
│   └── stats_dialog.dart       # 상세 통계 보기
├── services/
│   ├── supabase_service.dart   # Supabase API 호출
│   └── ai_service.dart         # AI 자동 분류 로직
└── providers/
    └── todo_provider.dart      # 상태 관리, 동기화

문서/
├── README.md                   # 이 파일
├── SUPABASE_SETUP.md          # Supabase 설정 가이드
├── ENV_SETUP.md               # 환경 변수 설정
├── DATABASE_UPDATE.sql        # DB 업데이트 SQL
└── QUICK_START.md             # 빠른 시작 가이드
```

---

## 🎮 사용 방법

### 기본 사용

1. **회원가입/로그인**
   - 이메일과 비밀번호로 가입
   - 자동으로 세션 유지

2. **할 일 추가**
   - `추가` 버튼 클릭 또는
   - 🎤 마이크 버튼으로 음성 입력

3. **할 일 관리**
   - 체크박스: 완료/미완료
   - 카드 클릭: 수정
   - 스와이프: 삭제
   - 드래그: 순서 변경

### 고급 기능

#### AI 자동 분류
```
할 일 입력: "내일 회의 준비하기"
   ↓
AI 자동 분류: 업무 카테고리
   ↓
우선순위 제안: 높음 (내일 마감)
```

#### 반복 일정
```
할 일: "매일 운동하기"
반복: 매일
   ↓
오늘 완료하면
   ↓
자동으로 내일 일정 생성! ✅
```

#### 서브태스크
```
할 일: "프로젝트 완성"
서브태스크:
  ☐ 디자인
  ☐ 개발
  ☐ 테스트
   ↓
진행률: [====  ] 40%
```

### 음성 인식 (Chrome)

1. 🎤 마이크 버튼 클릭
2. 마이크 권한 허용
3. 말하기: "내일까지 Flutter 공부하기"
4. 자동으로 할 일 추가 + AI 분류!

### 백업 & 복원

1. 👤 프로필 → 백업 & 복원
2. **내보내기**: JSON 파일 다운로드
3. **가져오기**: JSON 파일 업로드

---

## 🛠️ 기술 스택

### Frontend
- **Flutter** 3.35.5
- **Dart** 3.9.2
- **Material Design 3**
- **Provider** - 상태 관리
- **fl_chart** - 차트 라이브러리

### Backend
- **Supabase** - BaaS (Backend as a Service)
- **PostgreSQL** - 데이터베이스
- **Row Level Security** - 보안

### 핵심 패키지
```yaml
dependencies:
  supabase_flutter: ^2.0.0      # Supabase SDK
  provider: ^6.1.1               # 상태 관리
  shared_preferences: ^2.2.2     # 로컬 저장
  connectivity_plus: ^5.0.2      # 네트워크 감지
  flutter_dotenv: ^5.1.0         # 환경 변수
  uuid: ^4.0.0                   # UUID 생성
  fl_chart: ^0.65.0              # 통계 차트
  url_launcher: ^6.2.2           # URL 오픈
  universal_html: ^2.2.4         # 웹 파일 다운로드
```

---

## 🗄️ 데이터베이스 스키마

### todos 테이블
```sql
Column         | Type        | Description
---------------|-------------|---------------------------
id             | UUID        | 고유 ID (자동 생성)
user_id        | UUID        | 사용자 ID (auth.users FK)
title          | TEXT        | 할 일 제목
is_completed   | BOOLEAN     | 완료 여부
due_date       | TIMESTAMPTZ | 마감일
created_at     | TIMESTAMPTZ | 생성 시간
category       | TEXT        | 카테고리 (study, work 등)
notes          | TEXT        | 메모
links          | JSONB       | 링크 목록
sub_tasks      | JSONB       | 서브태스크 목록
repeat_type    | TEXT        | 반복 유형 (daily, weekly 등)
priority       | TEXT        | 우선순위 (low, medium, high)
project_id     | UUID        | 프로젝트 ID (향후 확장용)
```

### Row Level Security (RLS)
- 사용자는 자신의 할 일만 CRUD 가능
- JWT 토큰 기반 인증
- 안전한 멀티 테넌시

---

## 🎯 핵심 기능 상세

### 1. AI 자동 분류 🧠

**키워드 기반 자동 카테고리 분류:**
```
"회의" "미팅" "보고서" → 업무
"공부" "숙제" "과제" "시험" → 공부
"운동" "헬스" "러닝" → 운동
"프로젝트" "개발" "코딩" → 프로젝트
```

**우선순위 자동 제안:**
```
"긴급" "급한" "중요" → 높음
마감일이 1일 이내 → 높음
마감일이 3일 이내 → 보통
```

### 2. 반복 일정 ⏰

**작동 방식:**
```
할 일 완료 → 반복 유형 확인 → 다음 일정 자동 생성
```

**예시:**
- 매일: 오늘 완료 → 내일 자동 생성
- 매주: 월요일 완료 → 다음 주 월요일 생성
- 매달: 1일 완료 → 다음 달 1일 생성

### 3. 서브태스크 (체크리스트) ✅

**사용 예시:**
```
프로젝트 완성
├─ ☑ 디자인 (완료)
├─ ☐ 개발
├─ ☐ 테스트
└─ 진행률: [===   ] 33%
```

### 4. 클라우드 동기화 ☁️

**하이브리드 저장 방식:**
```
로컬 저장 (SharedPreferences)
    ↕️ 자동 동기화
클라우드 저장 (Supabase/PostgreSQL)
```

**자동 동기화 시점:**
- 앱 시작 시
- 로그인 시
- 오프라인 → 온라인 전환 시
- 데이터 변경 시 (추가/수정/삭제)

---

## 📊 통계 대시보드

### 메인 화면 통계 카드
- ✅ **완료**: X/Y 개 + 진행률 바
- 📅 **오늘**: 오늘 마감인 할 일 개수
- ⚠️ **지연**: 지연된 할 일 개수

### 상세 통계 (📈 버튼)
- **전체 통계**: 총 할 일, 완료율, 오늘 마감, 지연
- **주간 통계**: 최근 7일간 생성/완료
- **주간 그래프**: 월~일 완료율 꺾은선 차트
- **카테고리 분포**: 각 카테고리별 할 일 개수

---

## 🎨 디자인

### 색상 팔레트
- **Primary**: Deep Purple (#673AB7)
- **Accent**: Pink (#E91E63)
- **카테고리별 색상**:
  - 공부: Blue
  - 운동: Green
  - 프로젝트: Orange
  - 개인: Purple
  - 업무: Red
  - 기타: Grey

### 테마
- **라이트 모드**: 밝고 깔끔한 화이트 기반
- **다크 모드**: 눈에 편한 그레이 기반
- **자동 전환**: 우측 상단 아이콘으로 토글

---

## 🔒 보안

### 인증
- Supabase Auth 사용
- JWT 토큰 기반
- 세션 자동 관리 (7일 유효)

### 데이터 보호
- Row Level Security (RLS) 활성화
- 사용자별 데이터 완전 격리
- SQL Injection 방지
- XSS 공격 방지

### 환경 변수
- API 키를 코드에 노출하지 않음
- `.env` 파일로 관리 (Git에서 제외)
- 개발/프로덕션 환경 분리

---



## 📚 문서

| 문서 | 설명 |
|------|------|
| [SUPABASE_SETUP.md](SUPABASE_SETUP.md) | Supabase 프로젝트 설정 |
| [ENV_SETUP.md](ENV_SETUP.md) | 환경 변수 설정 |
| [QUICK_START.md](QUICK_START.md) | 빠른 시작 가이드 |
| [DATABASE_UPDATE.sql](DATABASE_UPDATE.sql) | DB 스키마 업데이트 |

---

## 🧪 테스트 시나리오

### 시나리오 1: AI 자동 분류
```
1. "회의 준비하기" 입력
2. AI가 자동으로 "업무" 카테고리 선택
3. 저장하면 업무 아이콘과 빨간색 표시
```

### 시나리오 2: 반복 일정
```
1. "매일 물 8잔 마시기" + 반복: 매일
2. 오늘 완료 체크
3. 자동으로 내일 일정 생성됨
```

### 시나리오 3: 다중 기기 동기화
```
1. 컴퓨터에서 할 일 추가
2. 폰에서 같은 계정 로그인
3. 자동으로 동기화됨!
```

### 시나리오 4: 음성 입력
```
1. 🎤 버튼 클릭
2. "내일까지 쇼핑하기" 말하기
3. 자동 추가 + AI가 "개인"으로 분류
```

---

## 💡 팁 & 트릭

### 빠른 할 일 추가
```
음성 입력 사용 → 5초만에 추가!
```

### 효율적인 관리
```
반복 일정 설정 → 매번 입력할 필요 없음
서브태스크 활용 → 큰 일을 작은 단위로
```

### 생산성 향상
```
통계 확인 → 완료율 체크 → 동기부여!
우선순위 활용 → 중요한 일 먼저
```

---

## 🐛 문제 해결

### 할 일이 DB에 안 들어가요
- [ ] 로그인했나요? (👤 아이콘 확인)
- [ ] `.env` 파일에 실제 Supabase 키 입력했나요?
- [ ] `DATABASE_UPDATE.sql` 실행했나요?
- [ ] 네트워크 연결되어 있나요?

### 음성 인식이 안 돼요
- [ ] Chrome 브라우저를 사용하나요?
- [ ] 마이크 권한을 허용했나요?
- [ ] HTTPS 또는 localhost에서 실행 중인가요?

### 동기화가 안 돼요
- [ ] 로그인 상태인가요?
- [ ] 네트워크 연결되어 있나요? (☁️❌ 아이콘 확인)
- [ ] 수동 동기화 시도해보세요

자세한 내용은 [문제 해결 가이드](#) 참고

---

## 🚀 배포

### 웹 배포

```bash
# 빌드
flutter build web

# build/web 폴더를 호스팅
# - Netlify
# - Vercel
# - Firebase Hosting
# - GitHub Pages
```

### 모바일 배포

```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios
```

---


## 📈 향후 계획

- [ ] 📱 위젯 지원 (홈 화면)
- [ ] 🔔 푸시 알림 (마감일 알림)
- [ ] 🤝 협업 기능 (할 일 공유)
- [ ] 📷 이미지 첨부
- [ ] 🗺️ 위치 기반 알림
- [ ] ⌚ Apple Watch / Wear OS 앱
- [ ] 🎨 커스텀 테마
- [ ] 📆 Google Calendar 연동

---

## 📝 라이선스

이 프로젝트는 포트폴리오용으로 제작되었습니다.

---

## 👨‍💻 개발자

**민하**
- Portfolio: [GitHub Profile](https://github.com/minhahamin)

## 🙏 감사의 말

- [Flutter](https://flutter.dev)
- [Supabase](https://supabase.com)
- [Material Design](https://material.io)


**Made with ❤️ and Flutter**