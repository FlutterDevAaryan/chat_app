import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../di/get_it.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';
import '../../utils/const/key_consts.dart';
import '../../utils/shared_prefs.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {

  ConversationBloc() : super(ConversationLoading()) {
    on<FetchMessages>(_handleFetchMessage);
    on<SendMessage>(_sendMessage);
  }

  Future<void> _handleFetchMessage(FetchMessages event, Emitter<ConversationState> emit) async {
      emit(ConversationLoading());
      try {
        final snapshot = await getIt<FirebaseFirestore>().collection(KeyConsts.CHAT_COLLECTION)
            .doc(event.chatId)
            .collection(KeyConsts.MESSAGE_COLLECTION)
            .orderBy(KeyConsts.TIME_STAMP, descending: true)
            .get();

        final messages = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        print("Emitting ConversationLoaded with messages: $messages");
        emit(ConversationLoaded(messages));
        print("ConversationLoaded state emitted with ${messages.length} messages.");
      } catch (e) {
        emit(ConversationError("Failed to fetch messages: $e"));
      }
  }

  Future<void> _sendMessage(SendMessage event, Emitter<ConversationState> emit) async {
      try {
        final messageRef = getIt<FirebaseFirestore>().collection(KeyConsts.CHAT_COLLECTION)
            .doc(event.chatId)
            .collection(KeyConsts.MESSAGE_COLLECTION)
            .doc();

        await messageRef.set({
          KeyConsts.SENDER_ID: event.senderId,
          KeyConsts.RECEIVER_ID: event.receiverId,
          KeyConsts.MESSAGE: event.message,
          KeyConsts.TIME_STAMP: FieldValue.serverTimestamp(),
        });

        await getIt<FirebaseFirestore>().collection(KeyConsts.CHAT_COLLECTION).doc(event.chatId).set({
          KeyConsts.LAST_MESSAGE: event.message,
          KeyConsts.SENDER_NAME: getIt<SharedPrefs>().getString(KeyConsts.PREF_USER_NAME),
          KeyConsts.LAST_MESSAGE_TIME: FieldValue.serverTimestamp(),
          KeyConsts.PARTICIPANTS: [event.senderId, event.receiverId],
        }, SetOptions(merge: true));

        final snapshot = await getIt<FirebaseFirestore>().collection(KeyConsts.CHAT_COLLECTION)
            .doc(event.chatId)
            .collection(KeyConsts.MESSAGE_COLLECTION)
            .orderBy(KeyConsts.TIME_STAMP, descending: true)
            .get();

        final messages = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        emit(ConversationLoaded(messages));
      } catch (e) {
        emit(ConversationError("Failed to send message: $e"));
      }
  }
}
