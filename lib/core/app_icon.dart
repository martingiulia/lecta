import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

/// Enum per tutte le icone usate nell'app
enum AppIconType {
  add,
  book,
  refresh,
  stop,
  play,
  playArrow,
  pause,
  edit,
  star,
  starOutline,
  fire,
  gift,
  bag,
  tablet,
  store,
  clock,
  remove,
  check,
  checkBoxOutlineBlank,
  error,
  info,
  menuBook,
  tabletMac,
  headphones,
  search,
  camera,
  // ...aggiungi qui altre icone usate nell'app
}

class AppIcon extends StatelessWidget {
  final AppIconType type;
  final double? size;
  final Color? color;

  const AppIcon(this.type, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(type);
    return Icon(iconData, size: size, color: color);
  }

  IconData _getIconData(AppIconType type) {
    if (Platform.isIOS) {
      switch (type) {
        case AppIconType.add:
          return CupertinoIcons.add;
        case AppIconType.book:
          return CupertinoIcons.book;
        case AppIconType.refresh:
          return CupertinoIcons.refresh;
        case AppIconType.stop:
          return CupertinoIcons.stop;
        case AppIconType.play:
          return CupertinoIcons.play_arrow_solid;
        case AppIconType.playArrow:
          return CupertinoIcons.play_arrow_solid;
        case AppIconType.pause:
          return CupertinoIcons.pause_solid;
        case AppIconType.edit:
          return CupertinoIcons.pencil;
        case AppIconType.star:
          return CupertinoIcons.star_fill;
        case AppIconType.starOutline:
          return CupertinoIcons.star;
        case AppIconType.fire:
          return CupertinoIcons.flame;
        case AppIconType.gift:
          return CupertinoIcons.gift;
        case AppIconType.bag:
          return CupertinoIcons.bag;
        case AppIconType.tablet:
          return CupertinoIcons.device_laptop;
        case AppIconType.store:
          return CupertinoIcons.shopping_cart;
        case AppIconType.clock:
          return CupertinoIcons.time;
        case AppIconType.remove:
          return CupertinoIcons.minus;
        case AppIconType.check:
          return CupertinoIcons.check_mark;
        case AppIconType.checkBoxOutlineBlank:
          return CupertinoIcons.square;
        case AppIconType.error:
          return CupertinoIcons.exclamationmark_triangle;
        case AppIconType.info:
          return CupertinoIcons.info;
        case AppIconType.menuBook:
          return CupertinoIcons.book;
        case AppIconType.tabletMac:
          return CupertinoIcons.device_laptop;
        case AppIconType.headphones:
          return CupertinoIcons.headphones;
        case AppIconType.search:
          return CupertinoIcons.search;
        case AppIconType.camera:
          return CupertinoIcons.camera;
        // ...altre corrispondenze
      }
    } else {
      // Default: Material
      switch (type) {
        case AppIconType.add:
          return Icons.add;
        case AppIconType.book:
          return Icons.book;
        case AppIconType.refresh:
          return Icons.refresh;
        case AppIconType.stop:
          return Icons.stop;
        case AppIconType.play:
          return Icons.play_arrow;
        case AppIconType.playArrow:
          return Icons.play_arrow;
        case AppIconType.pause:
          return Icons.pause;
        case AppIconType.edit:
          return Icons.edit;
        case AppIconType.star:
          return Icons.star;
        case AppIconType.starOutline:
          return Icons.star_border;
        case AppIconType.fire:
          return Icons.local_fire_department;
        case AppIconType.gift:
          return Icons.card_giftcard;
        case AppIconType.bag:
          return Icons.shopping_bag;
        case AppIconType.tablet:
          return Icons.tablet_mac;
        case AppIconType.store:
          return Icons.store;
        case AppIconType.clock:
          return Icons.access_time;
        case AppIconType.remove:
          return Icons.remove;
        case AppIconType.check:
          return Icons.check;
        case AppIconType.checkBoxOutlineBlank:
          return Icons.check_box_outline_blank;
        case AppIconType.error:
          return Icons.error_outline;
        case AppIconType.info:
          return Icons.info_outline;
        case AppIconType.menuBook:
          return Icons.menu_book;
        case AppIconType.tabletMac:
          return Icons.tablet_mac;
        case AppIconType.headphones:
          return Icons.headphones;
        case AppIconType.search:
          return Icons.search;
        case AppIconType.camera:
          return Icons.camera_alt;
        // ...altre corrispondenze
      }
    }
  }
}
