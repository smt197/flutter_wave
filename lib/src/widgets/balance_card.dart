import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'quick_action_button.dart';
import '../widgets/forms/transfer_form.dart';
import '../widgets/forms/deposit_form.dart';

class BalanceCard extends StatefulWidget {
  final String balance;
  final String qrCode; // QR Code en base64

  const BalanceCard({
    super.key,
    required this.balance,
    required this.qrCode,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _showQR = false;

  void _showTransferForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransferForm(),
    );
  }

  void _showDepositForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DepositForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Décodage du QR Code en base64 en Uint8List pour l'afficher comme image
    // Décodage du QR Code en base64 en Uint8List pour l'afficher comme image
    Uint8List? qrCodeImage;
    try {
      if (widget.qrCode.isNotEmpty) {
        // Vérifiez le préfixe MIME et extrayez seulement les données en base64
        final base64String = widget.qrCode.contains(',')
            ? widget.qrCode.split(',').last
            : widget.qrCode;

        // Décoder les données en base64
        qrCodeImage = base64Decode(base64String);
      }
    } catch (e) {
      print("Erreur lors du décodage de l'image : $e");
    }
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Solde disponible',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showQR ? Icons.qr_code : Icons.qr_code_outlined,
                      color: Colors.orange,
                    ),
                    onPressed: () {
                      setState(() {
                        _showQR = !_showQR;
                      });
                    },
                  ),
                  const Icon(Icons.visibility, color: Colors.orange),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (!_showQR) ...[
            Text(
              widget.balance,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _showDepositForm,
                  child: const QuickActionButton(
                    icon: Icons.add,
                    label: 'Dépôt',
                    color: Colors.green,
                  ),
                ),
                GestureDetector(
                  onTap: _showTransferForm,
                  child: const QuickActionButton(
                    icon: Icons.arrow_forward,
                    label: 'Transfert',
                    color: Colors.orange,
                  ),
                ),
                const QuickActionButton(
                  icon: Icons.phone_android,
                  label: 'Crédit',
                  color: Colors.blue,
                ),
              ],
            ),
          ] else if (qrCodeImage != null) ...[
            // Affichage du QR Code en image
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Image.memory(
                qrCodeImage,
                width: 180,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Scannez pour recevoir un paiement',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ] else ...[
            // Message si aucun QR Code n'est disponible
            const Text(
              'QR Code indisponible',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
