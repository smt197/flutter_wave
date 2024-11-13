import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/httpApiService.dart';

class DepositForm extends StatefulWidget {
  const DepositForm({super.key});

  @override
  State<DepositForm> createState() => _DepositFormState();
}

class _DepositFormState extends State<DepositForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedMethod;

  Future<void> submitDeposit() async {
    final amount = _amountController.text;
    final selectedMethod = _selectedMethod;

    if (selectedMethod == null) {
      return;
    }

    try {

      final httpApiService = HttpApiService();    
      final response = await httpApiService.submitDeposit(amount, selectedMethod);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dépôt réussi: ${response['message']}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final List<Map<String, dynamic>> _depositMethods = [
    {
      'name': 'Carte Bancaire',
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
    {
      'name': 'Orange Money',
      'icon': Icons.store,
      'color': Colors.orange,
    },
    {
      'name': 'Transfert Bancaire',
      'icon': Icons.account_balance,
      'color': Colors.green,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Text(
                  'Dépôt d\'argent',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section méthodes de dépôt
              const Text(
                'Choisir une méthode de dépôt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _depositMethods.length,
                itemBuilder: (context, index) {
                  final method = _depositMethods[index];
                  final isSelected = _selectedMethod == method['name'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMethod = method['name'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? method['color'].withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: method['color'])
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            method['icon'],
                            color: isSelected ? method['color'] : Colors.grey,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            method['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isSelected ? method['color'] : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Champ montant
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Montant à déposer',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null || amount < 500) {
                    return 'Montant minimum: 500 FCFA';
                  }
                  if (amount > 1000000) {
                    return 'Montant maximum: 1 000 000 FCFA';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Message d'information
              if (_selectedMethod != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getMethodMessage(_selectedMethod!),
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Bouton de validation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedMethod == null
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            submitDeposit();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirmer le dépôt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getMethodMessage(String method) {
    switch (method) {
      case 'Carte Bancaire':
        return 'Vous serez redirigé vers une page sécurisée pour effectuer le paiement par carte bancaire.';
      case 'Orange Money':
        return 'Rendez-vous chez un agent Orange Money avec le code qui sera généré pour effectuer votre dépôt.';
      case 'Transfert Bancaire':
        return 'Un RIB vous sera fourni pour effectuer le transfert depuis votre compte bancaire.';
      default:
        return '';
    }
  }
}
