# Todo List Pro

Flutter로 만든 고급 할 일 관리 앱 - PostgreSQL(Supabase) 기반 클라우드 동기화

## ✨ 주요 기능

### 📝 기본 기능
- ✅ 할 일 추가/수정/삭제
- ✅ 완료 체크/해제
- ✅ 마감일(Due Date) 설정
- ✅ 카테고리 분류 (공부, 운동, 프로젝트 등)
- ✅ 검색 기능
- ✅ 정렬 (날짜순, 마감일순, 카테고리순, 완료순)

### 🎨 UX 기능
- ✅ Drag & Drop 순서 변경
- ✅ 다크모드 지원
- ✅ 상세한 진행률 통계
- ✅ 스와이프하여 삭제
- ✅ 반응형 디자인

### ☁️ 클라우드 기능
- ✅ Supabase (PostgreSQL) 연동
- ✅ 이메일 로그인/회원가입
- ✅ 구글 OAuth 로그인
- ✅ 자동 클라우드 동기화
- ✅ 오프라인 지원 (로컬 저장)
- ✅ JSON 백업/복원

## 🚀 시작하기

### 필수 요구사항

- Flutter SDK 3.0.0 이상
- Dart SDK 3.0.0 이상
- Supabase 계정 (무료)

### 설치 및 실행

#### 1. 저장소 클론
```bash
git clone <repository-url>
cd to-do-list
```

#### 2. 의존성 설치
```bash
flutter pub get
```

#### 3. 환경 변수 설정
자세한 내용은 **ENV_SETUP.md** 참고

1. `.env` 파일에 Supabase 정보 입력:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

#### 4. Supabase 설정
자세한 내용은 **SUPABASE_SETUP.md** 참고

1. Supabase 프로젝트 생성
2. 데이터베이스 테이블 생성
3. 인증 설정

#### 5. 앱 실행
```bash
# 웹
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 📁 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── models/
│   └── todo_item.dart          # 데이터 모델
├── screens/
│   ├── todo_list_screen.dart   # 메인 화면
│   └── auth_screen.dart        # 로그인 화면
├── widgets/
│   ├── stat_card.dart          # 통계 카드
│   ├── category_chip.dart      # 카테고리 칩
│   └── todo_card.dart          # 할 일 카드
├── dialogs/
│   ├── todo_dialog.dart        # 추가/수정 다이얼로그
│   └── stats_dialog.dart       # 통계 다이얼로그
├── services/
│   └── supabase_service.dart   # Supabase API
└── providers/
    └── todo_provider.dart      # 상태 관리
```

## 🎯 사용 방법

### 할 일 관리
1. **추가**: 하단 `+` 버튼 클릭
2. **수정**: 할 일 카드 클릭
3. **완료**: 체크박스 클릭
4. **삭제**: 왼쪽으로 스와이프
5. **순서 변경**: 핸들(≡) 드래그

### 검색 및 필터
- 🔍 검색 아이콘: 제목/카테고리로 검색
- 🏷️ 카테고리 칩: 특정 카테고리 필터링
- 📊 정렬 버튼: 다양한 방식으로 정렬

### 통계 확인
- 📈 통계 아이콘: 상세한 진행률 확인
- 주간 통계, 카테고리별 분포 등

### 계정 관리
- 👤 프로필 아이콘: 계정 메뉴
- 수동 동기화, 백업/복원, 로그아웃

## 🔒 보안

- Row Level Security (RLS) 적용
- 사용자별 데이터 격리
- JWT 토큰 기반 인증
- 환경 변수로 API 키 관리

## 🌐 지원 플랫폼

- ✅ Web
- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📱 스크린샷

(여기에 앱 스크린샷 추가)

## 🛠️ 기술 스택

### Frontend
- **Flutter** 3.0+
- **Dart** 3.0+
- **Provider** - 상태 관리
- **Material Design 3**

### Backend
- **Supabase** - BaaS (Backend as a Service)
- **PostgreSQL** - 데이터베이스
- **Row Level Security** - 보안

### 패키지
- `supabase_flutter` - Supabase SDK
- `provider` - 상태 관리
- `shared_preferences` - 로컬 저장
- `connectivity_plus` - 네트워크 감지
- `flutter_dotenv` - 환경 변수
- `path_provider` - 파일 시스템
- `google_sign_in` - 구글 로그인

## 📚 문서

- [환경 변수 설정](ENV_SETUP.md)
- [Supabase 설정](SUPABASE_SETUP.md)

## 🤝 기여

기여는 언제나 환영합니다!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 라이선스

이 프로젝트는 포트폴리오용으로 제작되었습니다.

## 👨‍💻 개발자

**민하**
- Portfolio: [GitHub Profile](https://github.com/yourusername)

## 🙏 감사의 말

- [Flutter](https://flutter.dev)
- [Supabase](https://supabase.com)
- [Material Design](https://material.io)

## 🔮 향후 계획

- [ ] 실시간 협업 기능
- [ ] 푸시 알림
- [ ] 위젯 지원
- [ ] Apple Watch 앱
- [ ] 음성 입력
- [ ] AI 기반 추천