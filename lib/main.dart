import 'package:flutter/material.dart';
import 'package:flutter_wave/src/screens/HomeScreen.dart';
import 'src/services/bd/SharedPreferencesService.dart';
import 'package:provider/provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/screens/login_screen.dart';
// import 'src/services/httpApiService.dart';
import 'src/services/dioApiService.dart';
import './src/routes/route.dart';
import './utils/enums/apiEnum.dart';

void main() {
  disableSSLCertificateCheck();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(createApiService(),SharedPreferencesService()),
        ),
      ],
      child: MaterialApp(
        title: 'Wave Flutter',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: routes,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Vérification de l'authentification dès le lancement de l'application
            return FutureBuilder(
              future: authProvider.checkIfUserIsAuthenticated(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (authProvider.isAuthenticated) {
                  return const HomeScreen(); // Redirige vers la page d'accueil
                } else {
                  return const LoginScreen(); // Redirige vers la page de connexion
                }
              },
            );
          },
        ),
      ),
    );
  }
}
