import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/navigation/app_navigator.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'providers/life_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/shop_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'widgets/coin_reward_listener.dart';

late final ThemeProvider appThemeProvider;
late final LocaleProvider appLocaleProvider;
late final LifeProvider appLifeProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleFonts.pendingFonts([GoogleFonts.nunito()]);
  await StorageService.instance.init();
  await NotificationService.instance.init();

  appThemeProvider = ThemeProvider();
  await appThemeProvider.init();

  appLocaleProvider = LocaleProvider();
  await appLocaleProvider.init();

  appLifeProvider = LifeProvider();

  runApp(const LifeDashboardApp());
}

class LifeDashboardApp extends StatelessWidget {
  const LifeDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appThemeProvider),
        ChangeNotifierProvider.value(value: appLocaleProvider),
        ChangeNotifierProvider.value(value: appLifeProvider),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, theme, locale, _) {
          return Selector<ShopProvider, String>(
            selector: (_, shop) => shop.activeThemeId,
            builder: (context, themeId, _) {
              final shop = context.read<ShopProvider>();
              final preset = shop.activeTheme;
              final isDark = theme.isDarkMode;

              SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarColor: isDark ? preset.darkBackground : preset.background,
                systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              ));

              return MaterialApp(
                navigatorKey: rootNavigatorKey,
                title: 'Life Dashboard',
                debugShowCheckedModeBanner: false,
                theme: preset.lightTheme(),
                darkTheme: preset.darkTheme(),
                themeMode: theme.themeMode,
                locale: locale.locale,
                localeResolutionCallback: (_, supportedLocales) => supportedLocales.first,
                builder: (context, child) => CoinRewardListener(child: child ?? const SizedBox.shrink()),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en'), Locale('vi')],
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
