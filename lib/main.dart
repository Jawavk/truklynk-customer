import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truklynk/config/theme.dart';
import 'package:truklynk/pages/Order/providers/order_provider.dart';
import 'package:truklynk/routes/app_router.dart';
import 'package:truklynk/services/fire_base_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set edge-to-edge UI mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Optional: Customize system bar appearance
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Make status bar transparent
    systemNavigationBarColor:
        Colors.transparent, // Make navigation bar transparent
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  FireBaseService fireBaseService = FireBaseService();
  await fireBaseService.firebaseInit();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OrderDataProvider()),
        Provider<FireBaseService>(create: (_) => fireBaseService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'truklynk',
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: AppTheme.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
