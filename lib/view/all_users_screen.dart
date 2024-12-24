import 'package:chatapp/di/get_it.dart';
import 'package:chatapp/utils/const/key_consts.dart';
import 'package:chatapp/utils/shared_prefs.dart';
import 'package:chatapp/view/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/all_users/all_users_bloc.dart';
import '../bloc/all_users/all_users_event.dart';
import '../bloc/all_users/all_users_state.dart';

class AllUsersScreen extends StatefulWidget {
  const AllUsersScreen({super.key});

  @override
  State<AllUsersScreen> createState() => _AllUsersScreenState();
}


class _AllUsersScreenState extends State<AllUsersScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Users Screen',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 32
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: BlocConsumer<AllUsersBloc, AllUsersState>(
        listener: (BuildContext context, AllUsersState state) {
          if (state is ChatStarted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ConversationScreen(
                  chatId: state.chatId,
                  selectedUser: state.selectedUser,
                ),
              ),
            );
          }
        },
        builder: (BuildContext context, AllUsersState state) {
          if (state is AllUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AllUsersError) {
            return Center(child: Text(state.message));
          } else if (state is AllUsersLoaded) {
            return ListView.separated(
              itemCount: state.users.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> user = state.users[index];
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: user[KeyConsts.USER_PHOTO] ?? '',
                    placeholder: (BuildContext context, String url) => const CircleAvatar(
                        backgroundColor: Colors.green,
                        maxRadius: 24,
                        child: Icon(Icons.person, size: 24, color: Colors.white)),
                    errorWidget: (BuildContext context, String url, Object error) => const CircleAvatar(
                        backgroundColor: Colors.green,
                        maxRadius: 24,
                        child: Icon(Icons.person, size: 24, color: Colors.white)),
                    imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) => CircleAvatar(
                      backgroundImage: imageProvider,
                      radius: 24,
                    ),
                  ),
                  title: Text(
                    user[KeyConsts.USER_NAME] ?? 'Unknown User',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    user[KeyConsts.USER_EMAIL] ?? '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: const Icon(Icons.chat, color: Colors.green),
                  onTap: () {
                    final String currentUserId = getIt<SharedPrefs>().getString(KeyConsts.PREF_UID);
                    getIt<AllUsersBloc>().add(StartChatWithUser(currentUserId, user));
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(color: Colors.grey, height: 1);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getIt<AllUsersBloc>().add(FetchAllUsers());
  }
}
