import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen for authentication changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign in with Email & Password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Handle errors (e.g., user-not-found, wrong-password)
      rethrow;
    }
  }

  // Sign up with Email & Password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Create user document in Firestore
      await _createUserDocument(userCredential.user!, 'email');
    } catch (e) {
      // Handle errors (e.g., email-already-in-use)
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      // Check if this is a new user and create Firestore document
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDocument(userCredential.user!, 'google');
      }
      
      return userCredential;
    } catch (e) {
      // Handle errors
      rethrow;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String provider) async {
    try {
      // Check if document already exists
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();
      
      if (!docSnapshot.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? '',
          'photoURL': user.photoURL ?? '',
          'provider': provider,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update last login time
        await _firestore.collection('users').doc(user.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Log error but don't throw - user is already authenticated
      print('Error creating/updating user document: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}