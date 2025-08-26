import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Mevcut kullanıcı
  User? get currentUser => _auth.currentUser;

  // Kullanıcı durumu stream'i
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google ile giriş
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔍 Google Sign-In başlatılıyor...');
      
      // Google Sign-In başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Google Sign-In iptal edildi');
        return null;
      }

      print('✅ Google kullanıcı seçildi: ${googleUser.email}');
      print('🔑 Google kimlik bilgileri alınıyor...');

      // Google kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('✅ Google kimlik bilgileri alındı');
      print('📝 Access Token: ${googleAuth.accessToken != null ? "Var" : "Yok"}');
      print('📝 ID Token: ${googleAuth.idToken != null ? "Var" : "Yok"}');
      
      // Firebase kimlik bilgilerini oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔐 Firebase kimlik bilgileri oluşturuldu');
      print('🚀 Firebase ile giriş yapılıyor...');

      // Firebase ile giriş yap
      final userCredential = await _auth.signInWithCredential(credential);
      
      print('🎉 Google ile giriş başarılı: ${userCredential.user?.email}');
      print('🆔 User ID: ${userCredential.user?.uid}');
      return userCredential;
      
    } catch (e) {
      print('❌ Google ile giriş hatası: $e');
      print('📚 Hata detayı: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        print('🔥 Firebase Auth Hata Kodu: ${e.code}');
        print('🔥 Firebase Auth Hata Mesajı: ${e.message}');
      }
      return null;
    }
  }

  // Apple ile giriş
  Future<UserCredential?> signInWithApple() async {
    try {
      // Apple Sign-In başlat
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Firebase kimlik bilgilerini oluştur
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Firebase ile giriş yap
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      
      print('Apple ile giriş başarılı: ${userCredential.user?.email}');
      return userCredential;
      
    } catch (e) {
      print('Apple ile giriş hatası: $e');
      return null;
    }
  }

  // Misafir girişi
  Future<UserCredential?> signInAnonymously() async {
    try {
      print('👤 Misafir girişi başlatılıyor...');
      
      // Firebase ile anonim giriş yap
      final userCredential = await _auth.signInAnonymously();
      
      print('🎉 Misafir girişi başarılı!');
      print('🆔 Anonim User ID: ${userCredential.user?.uid}');
      print('📧 Email: ${userCredential.user?.email ?? "Yok (Anonim)"}');
      
      return userCredential;
      
    } catch (e) {
      print('❌ Misafir girişi hatası: $e');
      print('📚 Hata detayı: ${e.runtimeType}');
      if (e is FirebaseAuthException) {
        print('🔥 Firebase Auth Hata Kodu: ${e.code}');
        print('🔥 Firebase Auth Hata Mesajı: ${e.message}');
      }
      return null;
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('Çıkış başarılı');
    } catch (e) {
      print('Çıkış hatası: $e');
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
      print('Profil güncellendi');
    } catch (e) {
      print('Profil güncelleme hatası: $e');
    }
  }
}
