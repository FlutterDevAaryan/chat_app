import 'package:chatapp/bloc/all_users/all_users_bloc.dart';
import 'package:chatapp/bloc/conversation/conversation_bloc.dart';
import 'package:chatapp/bloc/home/home_bloc.dart';
import 'package:chatapp/bloc/login/login_bloc.dart';
import 'package:chatapp/bloc/profle/profile_bloc.dart';
import 'package:chatapp/services/firebase_notification_service.dart';
import 'package:chatapp/utils/shared_prefs.dart';
import 'package:chatapp/view/home_screen.dart';
import 'package:chatapp/view/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nested/nested.dart';

import 'bloc/profle/profile_event.dart';
import 'di/get_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await getItInitialise();
  await getIt<SharedPrefs>().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider(create: (BuildContext context) => getIt<LoginBloc>(),),
        BlocProvider(create: (BuildContext context) => getIt<HomeBloc>(),),
        BlocProvider(create: (BuildContext context) => getIt<AllUsersBloc>()),
        BlocProvider(create: (BuildContext context) => getIt<ConversationBloc>(),),
        BlocProvider(create: (BuildContext context) => getIt<ProfileBloc>()..add(FetchUserData()),),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder<User?>(
          stream: getIt<FirebaseAuth>().authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
            FirebaseNotificationService.initialize(context);
            FirebaseNotificationService.listenToFirestoreUpdates();
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
