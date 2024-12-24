import 'package:chatapp/utils/const/key_consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../../di/get_it.dart';
import '../../utils/shared_prefs.dart';

class FirebaseNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: androidInitializationSettings);

    await _localNotificationsPlugin.initialize(
      initializationSettings,
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else {
      debugPrint('User declined notification permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final chatId = message.data['chatId'];
      if (chatId != null) {
        Navigator.pushNamed(context, '/chat', arguments: chatId);
      }
    });
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel_id', 'Chat Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data['chatId'],
    );
  }

  static void listenToFirestoreUpdates() {
    getIt<FirebaseFirestore>().collection(KeyConsts.CHAT_COLLECTION).snapshots().listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      for (DocumentChange<Map<String, dynamic>> docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.modified) {
          final Map<String, dynamic> data = docChange.doc.data() as Map<String, dynamic>;
          final receiverId = data[KeyConsts.RECEIVER_ID];
          final lastMessage = data[KeyConsts.LAST_MESSAGE];
          final senderName = data[KeyConsts.SENDER_NAME];
          final String chatId = docChange.doc.id;

           final String currentUserId = getIt<SharedPrefs>().getString(KeyConsts.PREF_UID);

          if (receiverId == currentUserId) {
            _localNotificationsPlugin.show(
              0,
              senderName,
              lastMessage,
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  'chat_channel_id',
                  'Chat Notifications',
                  importance: Importance.high,
                  priority: Priority.high,
                ),
              ),
              payload: chatId,
            );
          }
        }
      }
    });
  }
}
