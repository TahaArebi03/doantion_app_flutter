import 'package:flutter/material.dart';
import '../models/member_model.dart';

class MemberCard extends StatelessWidget {
  final MemberModel member;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onRemove;

  const MemberCard({
    Key? key,
    required this.member,
    required this.onRoleChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              child: Text(member.fullName.isNotEmpty ? member.fullName[0] : 'U'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(member.email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            DropdownButton<String>(
              value: member.role,
              items: const [
                DropdownMenuItem(value: 'عضو', child: Text('عضو')),
                DropdownMenuItem(value: 'مشرف', child: Text('مشرف')),
                DropdownMenuItem(value: 'مدير مالي', child: Text('مدير مالي')),
              ],
              onChanged: (newRole) {
                if (newRole != null && newRole != member.role) {
                  onRoleChanged(newRole);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}