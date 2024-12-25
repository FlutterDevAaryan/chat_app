import 'package:bloc/bloc.dart';
import 'package:chatapp/di/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'all_users_event.dart';
import 'all_users_state.dart';
import '../../utils/const/key_consts.dart';
import '../../utils/shared_prefs.dart';

class AllUsersBloc extends Bloc<AllUsersEvent, AllUsersState> {

  AllUsersBloc() : super(AllUsersLoading()) {
    on<FetchAllUsers>((event, emit) async {
      emit(AllUsersLoading());
      try {
        final currentUserId = getIt<SharedPrefs>().getString(KeyConsts.PREF_UID);
        final querySnapshot = await getIt<FirebaseFirestore>().collection(KeyConsts.ALL_USERS_COLLECTION).get();
        final users = querySnapshot.docs
            .where((doc) => doc.id != currentUserId)
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        emit(AllUsersLoaded(users));

      } catch (e) {
        emit(AllUsersError("Failed to load users: $e"));
      }
    });

    on<StartChatWithUser>((event, emit) async {
      try {
        final currentUserId = event.currentUserId;
        final selectedUserId = event.selectedUser[KeyConsts.UNIQUE_ID];
        final chatId = generateChatId(currentUserId, selectedUserId);

        final chatDoc = await getIt<FirebaseFirestore>().collection(KeyConsts.CHAT_COLLECTION).doc(chatId).get();
        if (!chatDoc.exists) {
          await getIt<FirebaseFirestore>().collection(KeyConsts.CHAT_COLLECTION).doc(chatId).set({
            KeyConsts.PARTICIPANTS: [currentUserId, selectedUserId],
            KeyConsts.LAST_MESSAGE: "",
            KeyConsts.LAST_MESSAGE_TIME: FieldValue.serverTimestamp(),
          });
        }

        emit(ChatStarted(chatId, event.selectedUser));
      } catch (e) {
        emit(AllUsersError("Failed to start chat: $e"));
      }
    });
  }

  String generateChatId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Ensure consistent order
    return ids.join('_');
  }
}
