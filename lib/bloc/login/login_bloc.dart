import 'package:bloc/bloc.dart';
import 'package:chatapp/di/get_it.dart';
import 'package:chatapp/utils/const/key_consts.dart';
import 'package:chatapp/utils/shared_prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  LoginBloc() : super(LoginInitial()) {
    on<GoogleSignInRequested>(_handleGoogleSignIn);
  }

  Future<void> _handleGoogleSignIn(
      GoogleSignInRequested event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(LoginFailure("Google sign-in cancelled"));
        return;
      }


      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await getIt<FirebaseAuth>().signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final DocumentReference userDoc = getIt<FirebaseFirestore>().collection(KeyConsts.ALL_USERS_COLLECTION).doc(user.uid);

        await userDoc.set(<String, Object?>{
          KeyConsts.UNIQUE_ID: user.uid,
          KeyConsts.USER_NAME: user.displayName,
          KeyConsts.USER_EMAIL: user.email,
          KeyConsts.USER_PHOTO: user.photoURL,
          KeyConsts.USER_PHONE_NUMBER: user.phoneNumber,
          KeyConsts.LAST_LOGIN: DateTime.now(),
        }, SetOptions(merge: true));

        getIt<SharedPrefs>().setString(KeyConsts.PREF_USER_NAME, user.displayName);
        getIt<SharedPrefs>().setString(KeyConsts.PREF_UID, user.uid);
        getIt<SharedPrefs>().setString(KeyConsts.PREF_EMAIL, user.email);
        getIt<SharedPrefs>().setString(KeyConsts.PREF_PHONE_NUMBER, user.phoneNumber);
        getIt<SharedPrefs>().setString(KeyConsts.PREF_PHOTO, user.photoURL);

        emit(LoginSuccess());
      }
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
