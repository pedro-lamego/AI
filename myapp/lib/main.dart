import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:myapp/aspects/RouteConfig.dart';
import 'package:myapp/aspects/widgets/SplashScreen.dart';
import 'package:myapp/authentication/LoginPage.dart';
import 'package:myapp/home/HomePage.dart';
import 'package:myapp/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().catchError((onError) {
    print(onError.toString());
  });
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userStreamProvider);
    return MaterialApp(
        theme: ThemeData(
          backgroundColor: Color(0xFFF0A500),
          primaryColor: Color(0xFFE45826),
          hintColor: Color(0xFF241C1C),
          highlightColor: Color(0xFF0FAF63),
        ),
        routes: RouterConfig.routes,
        home: user.maybeWhen(
            data: (user) {
              if (user == null) return LoginPage();
              return HomePage();
            },
            loading: () => const SplashScreen(),
            orElse: () => Container(
                  color: Colors.red,
                )));
  }
}
