import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_example/dashboard_screen.dart';
import 'package:flutter_login_example/login_screen.dart';
import 'package:flutter_login_example/transition_route_observer.dart';

const Color orange = Color(0xFFF6911E);
const Color blue = Color(0xFF3852A3);
const Color blueDark = Color.fromARGB(255, 37, 55, 109);
const Color grey = Color(0xFFAAAAAA);
const Color bg = Color(0xFFefefef);
const Color yellow = Color(0xFFEB9F17);
const Color green = Color(0xFF53BE5E);
const Color divBlue = Color(0xFF5f82ff);
const Color white = Colors.white;
const Color darkBg = Color(0xFF161620);
const Color darkCont = Color(0xFF1c1c28);
const Color whatsGreen = Color(0xFF45b243);
void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor:
          SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        textSelectionTheme:
            const TextSelectionThemeData(cursorColor: Colors.orange),
        // fontFamily: 'SourceSansPro',
        textTheme: TextTheme(
          displaySmall: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 45.0,
            // fontWeight: FontWeight.w400,
            color: Colors.orange,
          ),
          labelLarge: const TextStyle(
            // OpenSans is similar to NotoSans but the uppercases look a bit better IMO
            fontFamily: 'OpenSans',
          ),
          bodySmall: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
            color: Colors.deepPurple[300],
          ),
          displayLarge: const TextStyle(fontFamily: 'Quicksand'),
          displayMedium: const TextStyle(fontFamily: 'Quicksand'),
          headlineMedium: const TextStyle(fontFamily: 'Quicksand'),
          headlineSmall: const TextStyle(fontFamily: 'NotoSans'),
          titleLarge: const TextStyle(fontFamily: 'NotoSans'),
          titleMedium: const TextStyle(fontFamily: 'NotoSans'),
          bodyLarge: const TextStyle(fontFamily: 'NotoSans'),
          bodyMedium: const TextStyle(fontFamily: 'NotoSans'),
          titleSmall: const TextStyle(fontFamily: 'NotoSans'),
          labelSmall: const TextStyle(fontFamily: 'NotoSans'),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(secondary: Colors.orange),
      ),
      // darkTheme: ThemeData.dark().copyWith(
      //   cardColor: darkCont,
      //   colorScheme: ColorScheme.fromSeed(
      //     surfaceTint: darkCont,
      //     seedColor: blue,
      //     brightness: Brightness.dark,
      //   ),
      //   scaffoldBackgroundColor: darkBg,
      //   cupertinoOverrideTheme: const CupertinoThemeData(
      //     brightness: Brightness.dark,
      //     scaffoldBackgroundColor: darkBg,
      //     barBackgroundColor: darkBg,
      //   ),
      //   textSelectionTheme: const TextSelectionThemeData(
      //     cursorColor: orange,
      //   ),
      // ),
      navigatorObservers: [TransitionRouteObserver()],
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        DashboardScreen.routeName: (context) => const DashboardScreen(),
      },
    );
  }
}
