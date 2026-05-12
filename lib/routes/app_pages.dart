import 'package:get/get.dart';
import 'package:piano_tiles/bindings/game_binding.dart';
import 'package:piano_tiles/bindings/menu_binding.dart';
import 'package:piano_tiles/bindings/splash_binding.dart';
import 'package:piano_tiles/views/game_page.dart';
import 'package:piano_tiles/views/menu_page.dart';
import 'package:piano_tiles/views/splash_page.dart';

abstract class AppPages {
  static const splash = '/';
  static const menu = '/menu';
  static const game = '/game';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: menu,
      page: () => const MenuPage(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: game,
      page: () => const GamePage(),
      binding: GameBinding(),
      preventDuplicates: false,
    ),
  ];
}