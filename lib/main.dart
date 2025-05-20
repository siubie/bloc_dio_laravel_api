import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_dio_laravel_api/pages/login_page.dart';
import 'package:bloc_dio_laravel_api/pages/signup_page.dart';
import 'package:bloc_dio_laravel_api/pages/home_page.dart';
import 'package:bloc_dio_laravel_api/blocs/login/login.dart';
import 'package:bloc_dio_laravel_api/core/configs/theme/app_theme.dart';
import 'package:bloc_dio_laravel_api/core/network/dio_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dioClient = DioClient();

  runApp(MyApp(dioClient: dioClient));
}

class MyApp extends StatelessWidget {
  final DioClient dioClient;

  const MyApp({super.key, required this.dioClient});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(dioClient: dioClient),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Auth Demo',
        theme: AppTheme.appTheme,
        routes: {
          '/': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/home': (context) => const HomePage(),
        },
        initialRoute: '/',
      ),
    );
  }
}
