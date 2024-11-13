import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _surnameController = TextEditingController();
  final _soldeController = TextEditingController();
  final _cumulController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _soldeMaxController = TextEditingController();
  String? _roleId;
  String? _statut;
  // String? _photoPath;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegex.hasMatch(email);
  }

  void _register() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  // Validation de l'email et des mots de passe, etc.

  // final clientData = {
  //   'surname': _surnameController.text,
  //   'telephone': _telephoneController.text,
  //   'adresse': _adresseController.text,
  //   'solde': int.tryParse(_soldeController.text) ?? 0, 
  //   'soldeMax': int.tryParse(_soldeMaxController.text) ?? 60000,
  //   'cumulTransaction': int.tryParse(_cumulController.text) ?? 100000,
  //};

  // final userData = {
  //   'name': _nameController.text,
  //   'email': _emailController.text,
  //   'password': _passwordController.text,
  //   'role_id': int.parse(_roleId!),  // Convertir en entier
  //   'statut': _statut,
  //   'telephone': _telephoneController.text,
  // };

  // Appeler l'authentification avec les données appropriées
  await authProvider.register({
    'surname': _surnameController.text,
  'telephone': _telephoneController.text,
  'adresse': _adresseController.text,
  'solde': int.tryParse(_soldeController.text) ?? 0,
  'soldeMax': int.tryParse(_soldeMaxController.text) ?? 60000,
  'cumulTransaction': int.tryParse(_cumulController.text) ?? 100000,
  'name': _nameController.text,
  'email': _emailController.text,
  'password': _passwordController.text,
  'role_id': int.parse(_roleId!),
  'statut': _statut,
  });

  // Affichage du message selon le résultat
  if (authProvider.isAuthenticated) {
    print('Inscription réussie');
    Navigator.pushReplacementNamed(context, '/home');
  } else if (authProvider.errorMessage != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authProvider.errorMessage!)),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo_wave.png',
                  height: 100,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Inscription',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                ),
                TextField(
                  controller: _confirmController,
                  decoration: const InputDecoration(labelText: 'Confirmation'),
                  obscureText: true,
                ),
                TextField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Surname'),
                ),
                TextField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                ),
                TextField(
                  controller: _adresseController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                ),
                TextField(
                  controller: _soldeController,
                  decoration: const InputDecoration(labelText: 'Solde'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _soldeMaxController,
                  decoration: const InputDecoration(labelText: 'Solde max'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _cumulController,
                  decoration: const InputDecoration(labelText: 'cumulTransaction'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButton<String>(
                  value: _roleId,
                  hint: const Text("Sélectionnez un rôle"),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text("Admin")),
                    DropdownMenuItem(value: '2', child: Text("Client")),
                    DropdownMenuItem(value: '3', child: Text("Distributeur")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _roleId = value;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: _statut,
                  hint: const Text("Sélectionnez un statut"),
                  items: const [
                    DropdownMenuItem(value: 'ACTIF', child: Text("Actif")),
                    DropdownMenuItem(value: 'INACTIF', child: Text("Inactif")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _statut = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Implémentation pour sélectionner une image
                  },
                  child: const Text("Télécharger une photo"),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _register,
                        child: const Text('Inscription'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
