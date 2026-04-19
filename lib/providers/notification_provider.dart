import 'package:flutter/material.dart';
import 'package:haweel/pages/mobile/notification_model.dart';

class NotificationProvider with ChangeNotifier {

  List<AppNotification> notifications = [];

  void addNotification(AppNotification notification) {

    notifications.insert(0, notification);

    notifyListeners();
  }

  void markAsRead(String id) {

    final index = notifications.indexWhere((n) => n.id == id);

    if (index != -1) {
      notifications[index] =
          notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
}