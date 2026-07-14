import 'package:flutter/material.dart';

class DonationCard extends StatelessWidget {
  final String donorName;
  final int amount;
  final String date;

  const DonationCard({
    super.key,
    required this.donorName,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.favorite)),
        title: Text(donorName),
        subtitle: Text(date),
        trailing: Text('\$${amount.toString()}'),
      ),
    );
  }
}
