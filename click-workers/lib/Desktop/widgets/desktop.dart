import 'package:flutter/material.dart';

enum DesktopPage {
  dashboard,
  tasks,
  ranking,
  rewards,
  wallet,
  settings,
  taskDetails,
  taskSubmission,
  editProfile,
  changeProfilePics,
  upgradePlan,
  preferredLanguage,
  preferredCurrency,
  changePassword,
  withdrawFunds,
  withdrawHistory
}

abstract class DeskTopHeader extends Widget {
  const DeskTopHeader({super.key});

  String get title;
  String? get subtitle;
}
