import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/service_button.dart';
import '../widgets/transaction_item.dart';
// import '../services/transaction_service.dart';
// import '../services/httpApiService.dart';
// import '../services/dioApiService.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  

  @override
  void initState() {
    super.initState();
  }

  Future<void> _logout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child:
                  Icon(Icons.person, color: Colors.orange.shade700, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Send Money',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Balance dynamique
              FutureBuilder<Map<String, dynamic>>(
                future: authProvider.balanceData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return const Text('Aucun solde disponible');
                  } else {
                    String balance = snapshot.data!['solde'].toString();
                    String qrCode = snapshot.data!['qr_code'];
                    return BalanceCard(
                      balance: '$balance FCFA',
                      qrCode: qrCode,
                    );
                  }
                },
              ),

              // Services fréquents
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Services fréquents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        ServiceButton(
                          icon: Icons.send,
                          label: 'Envoi\nd\'argent',
                          color: Colors.orange.shade600,
                        ),
                        ServiceButton(
                          icon: Icons.account_balance_wallet,
                          label: 'Retrait\nd\'argent',
                          color: Colors.blue.shade600,
                        ),
                        ServiceButton(
                          icon: Icons.payment,
                          label: 'Paiement\nfacture',
                          color: Colors.purple.shade600,
                        ),
                        ServiceButton(
                          icon: Icons.phone_android,
                          label: 'Forfait\nmobile',
                          color: Colors.green.shade600,
                        ),
                        ServiceButton(
                          icon: Icons.qr_code_scanner,
                          label: 'Scanner\nQR Code',
                          color: Colors.red.shade600,
                        ),
                        ServiceButton(
                          icon: Icons.more_horiz,
                          label: 'Plus de\nservices',
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Dernières transactions
              FutureBuilder<List<dynamic>>(
                future: authProvider.transactions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Aucune transaction disponible.'));
                  } else {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dernières transactions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Voir tout',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Afficher les transactions avec les informations du client
                          ...snapshot.data!.map((transaction) {
                            return TransactionItem(
                              title: transaction['type'] == 'transfert'
                                  ? 'Transfert envoyé'
                                  : 'Transfert reçu',
                              subtitle:
                                  'Client: ${transaction['client_name']} (${transaction['client_phone']})',
                              amount: '${transaction['amount']} FCFA',
                              date: transaction['created_at'],
                              icon: transaction['type'] == 'transfert'
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: transaction['type'] == 'transfert'
                                  ? Colors.red
                                  : Colors.green,
                            );
                          }),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Initialiser l'index actuel à 0
        onTap: (index) {
          if (index == 2) {
            // Appeler la méthode de déconnexion lorsque l'index est 2 (le dernier élément)
            _logout();
          } else {
            // Changer l'index actuel pour mettre à jour la navigation
            setState(() {
              var currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Déconnexion',
          ),
        ],
      ),
    );
  }
}
