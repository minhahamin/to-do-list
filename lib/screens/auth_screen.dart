import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../providers/todo_provider.dart';
import 'todo_list_screen.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final ThemeMode? themeMode;
  
  const AuthScreen({
    super.key,
    this.onToggleTheme,
    this.themeMode,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _supabase = SupabaseService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 에러 메시지 한글 변환
  String _getKoreanErrorMessage(dynamic error) {
    // Supabase AuthException 처리
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      final code = error.code?.toLowerCase() ?? '';
      
      // 로그인 관련
      if (code.contains('invalid_credentials') || 
          message.contains('invalid login credentials') ||
          message.contains('invalid email or password')) {
        return '이메일 또는 비밀번호가 올바르지 않습니다';
      }
      
      // 회원가입 관련
      if (code.contains('user_already_exists') ||
          message.contains('user already registered') || 
          message.contains('already been registered')) {
        return '이미 가입된 이메일입니다';
      }
      
      if (code.contains('email_not_confirmed') ||
          message.contains('email not confirmed')) {
        return '이메일 인증이 필요합니다. 이메일을 확인해주세요';
      }
      
      // 이메일 형식
      if (code.contains('invalid_email') || message.contains('invalid email')) {
        return '올바른 이메일 형식이 아닙니다';
      }
      
      // 비밀번호 관련
      if (message.contains('password') && 
          (message.contains('short') || message.contains('6 characters'))) {
        return '비밀번호는 최소 6자 이상이어야 합니다';
      }
      
      if (code.contains('weak_password') || 
          (message.contains('password') && message.contains('weak'))) {
        return '비밀번호가 너무 약합니다. 더 강력한 비밀번호를 사용해주세요';
      }
      
      // 네트워크/서버 에러
      if (error.statusCode != null) {
        switch (error.statusCode) {
          case '400':
            return '잘못된 요청입니다. 입력 정보를 확인해주세요';
          case '401':
            return '인증에 실패했습니다';
          case '403':
            return '접근 권한이 없습니다';
          case '404':
            return '요청한 리소스를 찾을 수 없습니다';
          case '422':
            return '입력 정보가 올바르지 않습니다';
          case '429':
            return '너무 많은 요청을 보냈습니다. 잠시 후 다시 시도해주세요';
          case '500':
          case '502':
          case '503':
            return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
        }
      }
    }
    
    // 일반 에러 처리
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('network') || errorStr.contains('timeout')) {
      return '네트워크 연결을 확인해주세요';
    }
    
    if (errorStr.contains('invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다';
    }
    
    // 알 수 없는 에러
    return '오류가 발생했습니다. 다시 시도해주세요';
  }

  Future<void> _handleEmailAuth() async {
    if (_emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty) {
      setState(() {
        _error = '이메일과 비밀번호를 입력해주세요';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_isLogin) {
        await _supabase.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await _supabase.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
      
      if (mounted) {
        // Provider 동기화
        final provider = Provider.of<TodoProvider>(context, listen: false);
        await provider.syncWithCloud();
        
        // TodoListScreen으로 이동
        if (widget.onToggleTheme != null && widget.themeMode != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => TodoListScreen(
                onToggleTheme: widget.onToggleTheme!,
                themeMode: widget.themeMode!,
              ),
            ),
          );
        } else {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      setState(() {
        _error = _getKoreanErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await _supabase.signInWithGoogle();
      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _error = _getKoreanErrorMessage(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: Colors.deepPurple.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Todo List Pro',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin ? '로그인' : '회원가입',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: '비밀번호',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _isLogin ? '로그인' : '회원가입',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Google 로그인 버튼 주석 처리 (설정이 복잡함)
                      // Row(
                      //   children: [
                      //     Expanded(child: Divider(color: Colors.grey[400])),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 16),
                      //       child: Text(
                      //         '또는',
                      //         style: TextStyle(color: Colors.grey[600]),
                      //       ),
                      //     ),
                      //     Expanded(child: Divider(color: Colors.grey[400])),
                      //   ],
                      // ),
                      // const SizedBox(height: 16),
                      // SizedBox(
                      //   width: double.infinity,
                      //   height: 50,
                      //   child: OutlinedButton.icon(
                      //     onPressed: _isLoading ? null : _handleGoogleSignIn,
                      //     icon: const Icon(Icons.login, size: 24),
                      //     label: const Text('Google로 계속하기'),
                      //     style: OutlinedButton.styleFrom(
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _error = null;
                          });
                        },
                        child: Text(
                          _isLogin
                              ? '계정이 없으신가요? 회원가입'
                              : '이미 계정이 있으신가요? 로그인',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
