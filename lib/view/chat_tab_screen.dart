import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/view/conversation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../di/get_it.dart';
import '../utils/const/key_consts.dart';
import '../utils/shared_prefs.dart';

class ChatTabScreen extends StatelessWidget {
  ChatTabScreen({super.key});
  final String _currentUserId =
  getIt<SharedPrefs>().getString(KeyConsts.PREF_UID);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: getIt<FirebaseFirestore>().collection(KeyConsts.CHAT_COLLECTION).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text("No chats yet."),
          );
        }

        // Get all chat documents
        final chatDocs = snapshot.data!.docs;

        // Filter chats involving the current user
        final userChats = chatDocs.where((doc) {
          final chatId = doc.id;
          return chatId.contains(_currentUserId);
        }).toList();

        // Extract the other participant IDs
        final chatDetails  = userChats.map((doc) {
          final chatId = doc.id;
          final lastMessage = doc[KeyConsts.LAST_MESSAGE];
          debugPrint(lastMessage);
          final participants = chatId.split('_'); // Split chatId by '_'
          final participantId = participants.first == _currentUserId
              ? participants.last
              : participants.first;
          return {
            'participantId': participantId,
            'lastMessage': lastMessage,
            'chatId': chatId,
          };

        }).toList();

        if (chatDetails.isEmpty) {
          return const Center(child: Text("No chats yet."));
        }

        return ListView.separated(
          itemCount: chatDetails.length,
          itemBuilder: (context, index) {
            final chat = chatDetails[index];
            final participantId = chat['participantId'];
            final lastMessage = chat['lastMessage'];
            final chatId = chat['chatId'];

            return FutureBuilder<DocumentSnapshot>(
              future: getIt<FirebaseFirestore>().collection(KeyConsts.ALL_USERS_COLLECTION).doc(participantId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const SizedBox(); // Skip if user details are not available
                }

                // Extract user details from the "users" document
                final userData =
                userSnapshot.data!.data() as Map<String, dynamic>;
                final userName = userData[KeyConsts.USER_NAME] ?? 'Unknown User';
                final userPhoto = userData[KeyConsts.USER_PHOTO] ?? '';

                return ListTile(
                  leading: CachedNetworkImage(
                      imageUrl: userPhoto,
                      placeholder: (context, url) => const CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 24,
                          child: Icon(Icons.person, size: 24,color: Colors.white,)),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 24,
                          child: Icon(Icons.person, size: 24,color: Colors.white,)),
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                        radius: 24,
                      ),
                    ),
                  title: Text(userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                  subtitle: Text(lastMessage),
                  onTap: () {
                    // Navigate to the individual chat screen with `participantId`
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ConversationScreen(
                              chatId: chatId,
                              selectedUser: userData,
                            ), // Replace with your chat screen
                      ),
                    );
                  },
                );
              },
            );
          }, separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              height: 1,
              color: Colors.grey,
            );
        },
        );
      },
    );
  }
}

// Dummy ChatScreen for navigation (replace with your actual ChatScreen implementation)
class ChatScreen extends StatelessWidget {
  final String chatUserId;
  const ChatScreen({required this.chatUserId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with $chatUserId')),
      body: Center(child: Text('Chat screen for $chatUserId')),
    );

  }
}