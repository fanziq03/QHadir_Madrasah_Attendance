import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

Widget addBadgeCount(
  {
    required Widget widget,
    required int badgeCount,
    Color badgeColor = Colors.deepPurple,
    Color textColor = Colors.white,
    badges.BadgeShape badgeShape = badges.BadgeShape.circle
  }
)
{
  return badges.Badge(
    showBadge: badgeCount != 0,
    badgeContent: Text(
      badgeCount.toString(),
      style: TextStyle(
        color: textColor,
      ),
    ),
    badgeStyle: badges.BadgeStyle(
      badgeColor: badgeColor,
      shape: badgeShape
    ),
    child: widget,
  );
}

// Contoh penggunaan:

// addBadgeCount(
//   widget: SvgPicture.asset(  - Widget yg ingin ada badge
//     data.img,
//     width: 60,
//     colorFilter: const ColorFilter.mode(
//       Colors.white,
//       BlendMode.srcIn,
//     ),
//   ),
//   badgeCount: 3,             - Kat sini bole ltk int berapa
//   badgeColor: Colors.red     - Pilih color bulatan badge
//   textColor: Colors.white    - Pilih color text dalam badge (nombor)
// )