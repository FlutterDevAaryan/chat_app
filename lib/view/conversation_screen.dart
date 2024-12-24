import 'package:chatapp/di/get_it.dart';
import 'package:chatapp/utils/const/key_consts.dart';
import 'package:chatapp/utils/shared_prefs.dart';
import 'package:chatapp/utils/toast_message_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/conversation/conversation_bloc.dart';
import '../bloc/conversation/conversation_event.dart';
import '../bloc/conversation/conversation_state.dart';

class ConversationScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic> selectedUser;

  const ConversationScreen({super.key, required this.chatId, required this.selectedUser});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  TextEditingController messageTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Trigger fetching messages
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // Future.microtask(() =>
        getIt<ConversationBloc>().add(FetchMessages(widget.chatId));
    //   ,);
    // });
  }

  @override
  void dispose() {
    messageTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedUser[KeyConsts.USER_NAME]),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 32,
        ),
      ),
      body: Column( // Column is a Flex widget
        children: <Widget>[
          Flexible(
            child: BlocBuilder<ConversationBloc, ConversationState>(
              builder: (BuildContext context, ConversationState state) {
                if (state is ConversationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ConversationError) {
                  return Center(child: Text(state.message));
                } else if (state is ConversationLoaded) {
                  final List<Map<String, dynamic>> messages = state.messagess;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> message = messages[index];
                      final bool isMe = message[KeyConsts.SENDER_ID] ==
                          getIt<SharedPrefs>().getString(KeyConsts.PREF_UID);

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(message[KeyConsts.MESSAGE]),
                              const SizedBox(height: 5),
                              Text(
                                formatTimestamp(
                                  message[KeyConsts.TIME_STAMP],
                                ),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),

          // Message Input Field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageTextController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final String text = messageTextController.text.trim();
                      if (text.isNotEmpty) {
                        getIt<ConversationBloc>().add(SendMessage(
                          widget.chatId,
                          getIt<SharedPrefs>().getString(KeyConsts.PREF_UID),
                          widget.selectedUser[KeyConsts.UNIQUE_ID],
                          text,
                        ));
                        messageTextController.clear();
                      } else {
                        ToastMessage.warning(message: "Please write something");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final DateTime date = timestamp.toDate();
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inSeconds < 60) return "Just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes} min ago";
    if (difference.inHours < 24) return "${difference.inHours} hours ago";
    if (difference.inDays < 7) return "${difference.inDays} days ago";
    return "${date.day}/${date.month}/${date.year}";
  }
}
