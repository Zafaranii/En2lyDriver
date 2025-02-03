import 'package:flutter/material.dart';

import '../../../Models/card_model.dart';
import 'add_payemnt.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  List<PaymentCard> savedCards = []; // List to store saved cards
  PaymentCard? defaultCard; // Track the selected default payment card
  String selectedPaymentMethod = 'Credit'; // Default payment method

  void _setDefaultCard(PaymentCard card) {
    setState(() {
      defaultCard = card;
    });
  }

  void _submitDefaultPaymentMethod() {
    if (selectedPaymentMethod == 'Credit' && defaultCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a default payment card'),
        ),
      );
      return;
    }

    // Submit the selected payment method
    print('Selected Payment Method: $selectedPaymentMethod');
    if (defaultCard != null) {
      print('Default Card Submitted: ${defaultCard!.cardNumber}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment Method Submitted: $selectedPaymentMethod',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color navy = Color(0xFF2D3E50);
    const Color lightGrey = Color(0xFFF3F4F6);
    const Color blue = Color(0xFF535AFF);
    const Color darkGrey = Color(0xFF4A4A4A);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: navy,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          color: lightGrey,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Payment Method:',
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Credit'),
                      value: 'Credit',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                      activeColor: blue,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Cash'),
                      value: 'Cash',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                          defaultCard = null; // Clear default card when Cash is selected
                        });
                      },
                      activeColor: blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Chosen Payment Method: $selectedPaymentMethod',
                style: const TextStyle(
                  color: darkGrey,
                  fontSize: 16,
                ),
              ),
              if (selectedPaymentMethod == 'Credit') ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    // Navigate to the Add Payment Method page
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPaymentMethodPage(),
                      ),
                    );
                    // Update the saved cards when returning
                    if (result is PaymentCard) {
                      setState(() {
                        savedCards.add(result);
                      });
                    }
                  },
                  child: const Text(
                    'Add Payment Method',
                    style: TextStyle(
                      color: blue,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Saved Cards:',
                  style: TextStyle(
                    color: darkGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                savedCards.isEmpty
                    ? const Text(
                  'No cards added yet',
                  style: TextStyle(color: darkGrey),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: savedCards.length,
                  itemBuilder: (context, index) {
                    final card = savedCards[index];
                    return ListTile(
                      leading: const Icon(Icons.credit_card, color: blue),
                      title: Text(card.cardHolderName,
                          style: const TextStyle(color: darkGrey)),
                      subtitle: Text(
                        'Card Number: ${card.cardNumber}',
                        style: const TextStyle(color: darkGrey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<PaymentCard>(
                            value: card,
                            groupValue: defaultCard,
                            onChanged: (PaymentCard? selectedCard) {
                              _setDefaultCard(selectedCard!);
                            },
                            activeColor: blue,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: blue),
                            onPressed: () {
                              setState(() {
                                if (defaultCard == card) {
                                  defaultCard = null;
                                }
                                savedCards.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const Spacer(),
              ElevatedButton(
                onPressed: _submitDefaultPaymentMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Payment Method',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}