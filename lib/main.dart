import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/todo_list_screen.dart';
import 'screens/auth_screen.dart';
import 'providers/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 변수 로드 (웹에서는 에러 처리)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('⚠️ .env 파일을 로드할 수 없습니다. 기본값 사용.');
  }

  // Supabase 초기화
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zdtefhneaiguasckzmvi.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpkdGVmaG5lYWlndWFzY2t6bXZpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2NDM1MDUsImV4cCI6MjA3NTIxOTUwNX0.VgNJ9R9OFyE7CNo0gWw5yeoUw8dl544yzXJKoRPkf3U',
  );

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? supabaseUrl,
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? supabaseAnonKey,
  );

  runApp(const TodoApp());
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: MaterialApp(
        title: 'Todo List Pro',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.grey[900],
        ),
        home: SplashScreen(onToggleTheme: _toggleTheme, themeMode: _themeMode),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const SplashScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Supabase 세션 확인
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      // 이미 로그인되어 있으면 바로 메인 화면으로 ✅
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TodoListScreen(
            onToggleTheme: widget.onToggleTheme,
            themeMode: widget.themeMode,
          ),
        ),
      );
    } else {
      // 로그인 안 되어 있으면 인증 화면으로
      final shouldContinue = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );

      if (!mounted) return;

      if (shouldContinue != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TodoListScreen(
              onToggleTheme: widget.onToggleTheme,
              themeMode: widget.themeMode,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.deepPurple.shade200,
              Colors.pink.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Todo List Pro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}