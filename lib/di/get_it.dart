import 'package:chatapp/bloc/all_users/all_users_bloc.dart';
import 'package:chatapp/bloc/conversation/conversation_bloc.dart';
import 'package:chatapp/bloc/home/home_bloc.dart';
import 'package:chatapp/bloc/login/login_bloc.dart';
import 'package:chatapp/bloc/profle/profile_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/shared_prefs.dart';

GetIt getIt = GetIt.instance;

Future<void> getItInitialise() async {

  getIt.registerSingleton<SharedPrefs>(
    SharedPrefs.getInstance(),
  );

  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<GoogleSignIn>(GoogleSignIn());

  getIt.registerSingleton<LoginBloc>(LoginBloc());
  getIt.registerSingleton<HomeBloc>(HomeBloc());
  getIt.registerSingleton<AllUsersBloc>(AllUsersBloc());
  getIt.registerLazySingleton<ConversationBloc>(() => ConversationBloc());
  getIt.registerSingleton<ProfileBloc>(ProfileBloc());
}
