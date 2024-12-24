import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/di/get_it.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/profle/profile_bloc.dart';
import '../bloc/profle/profile_event.dart';
import '../bloc/profle/profile_state.dart';
import '../utils/const/key_consts.dart';
import '../utils/utils.dart';

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
          if (state is ProfileLoaded) {
            return FloatingActionButton(
              backgroundColor: Colors.green,
              child: Icon(state.isEditing ? Icons.close : Icons.edit,
                  color: Colors.white),
              onPressed: () {
                getIt<ProfileBloc>().add(ToggleEditMode());
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(child: Text(state.error));
          } else if (state is ProfileLoaded) {
            final TextEditingController nameController = TextEditingController(
                text: state.userData[KeyConsts.USER_NAME] ?? '');
            final TextEditingController emailController = TextEditingController(
                text: state.userData[KeyConsts.USER_EMAIL] ?? '');
            final TextEditingController phoneController = TextEditingController(
                text: state.userData[KeyConsts.USER_PHONE_NUMBER] ?? '');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: Utils.height(context) * 0.05),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: state.userData[KeyConsts.USER_PHOTO] ?? '',
                        placeholder: (BuildContext context, String url) => const CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 60,
                          child: Icon(Icons.person,
                              size: 60, color: Colors.white),
                        ),
                        errorWidget: (BuildContext context, String url, Object error) =>
                            const CircleAvatar(
                          backgroundColor: Colors.green,
                          radius: 60,
                          child: Icon(Icons.person,
                              size: 60, color: Colors.white),
                        ),
                        imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) =>
                            CircleAvatar(
                          backgroundImage: imageProvider,
                          radius: 60,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildProfileField(
                    label: 'Name',
                    controller: nameController,
                    isEditing: state.isEditing,
                  ),
                  const SizedBox(height: 15),
                  _buildProfileField(
                    label: 'Email',
                    controller: emailController,
                    isEditing: state.isEditing,
                  ),
                  const SizedBox(height: 15),
                  _buildProfileField(
                    label: 'Phone',
                    controller: phoneController,
                    isEditing: state.isEditing,
                  ),
                  const SizedBox(height: 40),
                  // Save or Sign Out Button
                  ElevatedButton(
                    onPressed: () async {
                      if (state.isEditing) {
                        getIt<ProfileBloc>().add(UpdateUserDetails(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              phone: phoneController.text.trim(),
                            ));
                      } else {
                        await getIt<FirebaseAuth>().signOut();
                        Navigator.popUntil(context, (Route route) => route.isFirst);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      state.isEditing ? 'Save' : 'Sign Out',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
  }) {
    return Row(
      children: <Widget>[
        Text('$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(width: 10),
        Expanded(
          child: isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                )
              : Text(
                  controller.text.isNotEmpty ? controller.text : 'Not provided',
                  style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
