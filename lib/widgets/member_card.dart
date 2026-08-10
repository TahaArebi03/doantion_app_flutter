import 'package:flutter/material.dart';
import '../models/member_model.dart';

class MemberCard extends StatelessWidget {
  final MemberModel member;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onRemove;
  final bool canEdit;

  const MemberCard({
    Key? key,
    required this.member,
    required this.onRoleChanged,
    required this.onRemove,
    this.canEdit = false,
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
              child: Text(
                member.fullName.isNotEmpty ? member.fullName[0] : 'U',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    member.email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (canEdit)
              DropdownButton<String>(
                value: member.role,
                items: const [
                  DropdownMenuItem(value: 'member', child: Text('عضو')),
                  DropdownMenuItem(value: 'admin', child: Text('مشرف')),
                  DropdownMenuItem(
                    value: 'finance_manager',
                    child: Text('مدير مالي'),
                  ),
                ],
                onChanged: (newRole) {
                  if (newRole != null && newRole != member.role) {
                    onRoleChanged(newRole);
                  }
                },
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getRoleColor(member.role).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  MemberModel.translateRole(member.role),
                  style: TextStyle(color: _getRoleColor(member.role)),
                ),
              ),
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.blue;
      case 'finance_manager':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}
