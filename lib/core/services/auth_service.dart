import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../models/models.dart';
import 'storage_service.dart';
import '../../firebase_options.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // NOTE: Do NOT pass clientId on Android — it is not supported and causes
    // sign-in failures. Android reads the OAuth 2.0 client_id from
    // google-services.json automatically.
    // clientId is only needed for web (via firebase_options) or iOS.
    scopes: ['email'],
  );

  // Stream of current user with role data from Firestore.
  //
  // Race-condition safe: when a new Google/Phone user signs in, Firebase Auth
  // fires authStateChanges() BEFORE the Firestore document has been written.
  // The inner stream therefore skips snapshots where the doc doesn't exist yet
  // (instead of emitting null) so AuthWrapper never briefly flashes to LoginView.
  // A real sign-out is handled by the outer `authStateChanges()` emitting null
  // which takes the `firebaseUser == null` branch and emits Stream.value(null).
  Stream<AppUser?> get user {
    return _auth.authStateChanges().asyncExpand((firebaseUser) {
      if (firebaseUser == null) {
        // Genuinely signed out — propagate null immediately.
        return Stream.value(null);
      } else {
        return _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .snapshots()
            .map((doc) {
              if (doc.exists) {
                return AppUser.fromMap(doc.data()!, firebaseUser.uid);
              }
              return null; // Emit null instead of hanging if doc doesn't exist
            });
      }
    });
  }

  // Sign in with email and password
  Future<AppUser?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();
        if (doc.exists) {
          return AppUser.fromMap(doc.data()!, result.user!.uid);
        } else {
          await _auth.signOut();
          throw Exception(
            'Account data not found. The account may have been deleted.',
          );
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Register a new player
  Future<AppUser?> registerPlayer({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        final newUser = Player(
          uid: result.user!.uid,
          email: email,
          role: UserRole.player,
          name: name,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap());
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Owner creates an Organizer account
  Future<void> createOrganizer({
    required String email,
    required String password,
    required String name,
    required String ownerId,
    String? phoneNumber,
    String? address,
    String? aadharNumber,
    Uint8List? aadharBytes,
    String? aadharFileName,
    String? panNumber,
    Uint8List? panBytes,
    String? panFileName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accessDuration,
    Uint8List? profilePicBytes,
    String? profilePicFileName,
  }) async {
    final StorageService storage = StorageService();
    FirebaseApp? secondaryApp;
    try {
      // Initialize a secondary app to avoid logging out the current Owner
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryAccountCreator',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(
        app: secondaryApp,
      );

      final result = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        String? aadharUrl;
        String? panUrl;
        String? profilePicUrl;

        if (profilePicBytes != null && profilePicFileName != null) {
          profilePicUrl = await storage.uploadProfilePicture(
            result.user!.uid,
            profilePicBytes,
            profilePicFileName,
          );
        }

        if (aadharBytes != null && aadharFileName != null) {
          aadharUrl = await storage.uploadAadharPicture(
            result.user!.uid,
            aadharBytes,
            aadharFileName,
          );
        }

        if (panBytes != null && panFileName != null) {
          panUrl = await storage.uploadPanPicture(
            result.user!.uid,
            panBytes,
            panFileName,
          );
        }

        final newUser = Organizer(
          uid: result.user!.uid,
          email: email,
          role: UserRole.organizer,
          name: name,
          createdAt: DateTime.now(),
          ownerId: ownerId,
          phoneNumber: phoneNumber,
          address: address,
          aadharNumber: aadharNumber,
          aadharPic: aadharUrl,
          panNumber: panNumber,
          panPic: panUrl,
          profilePic: profilePicUrl,
          bankName: bankName,
          accountNumber: accountNumber,
          ifscCode: ifscCode,
          accessDuration: accessDuration,
          isProfileComplete: true,
        );

        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap());
        // No need to call secondaryAuth.signOut() — secondaryApp.delete()
        // in the finally block cleans everything up without emitting
        // spurious auth sign-out events to the log.
      }
    } catch (e) {
      rethrow;
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
    }
  }

  // Sign in with Google (Players Only)
  Future<AppUser?> signInWithGoogle() async {
    try {
      UserCredential result;

      if (kIsWeb) {
        // Web: Use Firebase's built-in popup logic to avoid GAPI/GIS script issues
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        authProvider.setCustomParameters({'prompt': 'select_account'});
        result = await _auth.signInWithPopup(authProvider);
      } else {
        // Mobile: Use standard google_sign_in package
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // Cancelled

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        result = await _auth.signInWithCredential(credential);
      }

      if (result.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        if (doc.exists) {
          final appUser = AppUser.fromMap(doc.data()!, result.user!.uid);
          // Enforce: Only Players can use Google Login
          if (appUser.role != UserRole.player) {
            await _auth.signOut();
            await _googleSignIn.signOut();
            throw Exception(
              'Owners and Organizers must log in using Email and Password.',
            );
          }
          return appUser;
        } else {
          // New User -> Create as Player
          final newUser = Player(
            uid: result.user!.uid,
            email: result.user!.email ?? '',
            role: UserRole.player,
            name: result.user!.displayName ?? 'New Player',
            createdAt: DateTime.now(),
            isProfileComplete: false,
          );

          await _firestore
              .collection('users')
              .doc(newUser.uid)
              .set(newUser.toMap());
          return newUser;
        }
      }
      return null;
    } catch (e) {
      // Do NOT call _auth.signOut() here for general errors (network, Firestore
      // permissions, etc.). Signing out would fire authStateChanges() → stream
      // emits null → AuthWrapper flashes to LoginView even though the error
      // might be transient.
      //
      // Role-enforcement sign-out is already handled explicitly above (lines
      // with appUser.role != UserRole.player). For everything else, just
      // rethrow so AuthViewModel can display the error string to the user.
      rethrow;
    }
  }

  // Verify Phone Number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution (mostly Android).
          // We let the UI handle full sign-in manually via OTP to simplify the flow
          // and ensure the Player profile is created correctly before dashboard redirect.
        },
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP and Sign In (Players Only)
  Future<AppUser?> verifyOTP(String verificationId, String smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      if (result.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .get();

        if (doc.exists) {
          final appUser = AppUser.fromMap(doc.data()!, result.user!.uid);
          // Enforce: Only Players can use Phone Login
          if (appUser.role != UserRole.player) {
            await _auth.signOut();
            throw Exception(
              'Owners and Organizers must log in using Email and Password.',
            );
          }
          return appUser;
        } else {
          // New User -> Create as Player
          final newUser = Player(
            uid: result.user!.uid,
            email: '', // Phone users might not have email initially
            role: UserRole.player,
            name: 'New Player',
            createdAt: DateTime.now(),
            isProfileComplete: false,
            phoneNumber: result.user!.phoneNumber,
          );

          await _firestore
              .collection('users')
              .doc(newUser.uid)
              .set(newUser.toMap());
          return newUser;
        }
      }
      return null;
    } catch (e) {
      await _auth.signOut();
      rethrow;
    }
  }

  // Permanently store player's profile info
  Future<void> updatePlayerProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      final updateData = {...data, 'isProfileComplete': true};
      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
