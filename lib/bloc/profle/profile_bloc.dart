import 'package:chatapp/bloc/profle/profile_event.dart';
import 'package:chatapp/bloc/profle/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../di/get_it.dart';
import '../../utils/const/key_consts.dart';
import '../../utils/shared_prefs.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileLoading()) {
    on<FetchUserData>(_onFetchUserData);
    on<ToggleEditMode>(_onToggleEditMode);
    on<UpdateUserDetails>(_onUpdateUserDetails);
  }

  Future<void> _onFetchUserData(FetchUserData event, Emitter<ProfileState> emit) async {
    try {
      final userId = getIt<SharedPrefs>().getString(KeyConsts.PREF_UID);
      final doc = await getIt<FirebaseFirestore>()
          .collection(KeyConsts.ALL_USERS_COLLECTION)
          .doc(userId)
          .get();

      if (doc.exists) {
        emit(ProfileLoaded(userData: doc.data() ?? {}));
      } else {
        emit(ProfileError('User data not found.'));
      }
    } catch (e) {
      emit(ProfileError('Failed to fetch user data: $e'));
    }
  }

  void _onToggleEditMode(ToggleEditMode event, Emitter<ProfileState> emit) {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      emit(ProfileLoaded(userData: currentState.userData, isEditing: !currentState.isEditing));
    }
  }

  Future<void> _onUpdateUserDetails(UpdateUserDetails event, Emitter<ProfileState> emit) async {
    try {
      final userId = getIt<SharedPrefs>().getString(KeyConsts.PREF_UID);

      await getIt<FirebaseFirestore>()
          .collection(KeyConsts.ALL_USERS_COLLECTION)
          .doc(userId)
          .set({
        KeyConsts.USER_NAME: event.name,
        KeyConsts.USER_EMAIL: event.email,
        KeyConsts.USER_PHONE_NUMBER: event.phone,
      }, SetOptions(merge: true));

      emit(ProfileLoaded(
        userData: {
          KeyConsts.USER_NAME: event.name,
          KeyConsts.USER_EMAIL: event.email,
          KeyConsts.USER_PHONE_NUMBER: event.phone,
        },
        isEditing: false,
      ));
    } catch (e) {
      emit(ProfileError('Failed to update user details: $e'));
    }
  }
}
