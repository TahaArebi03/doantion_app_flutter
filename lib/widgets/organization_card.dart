import 'package:flutter/material.dart';
import '../models/organization_model.dart';

class OrganizationCard extends StatelessWidget {
  final Organization organization;
  final VoidCallback onTap;
  final Future<void> Function() onFollowToggle;
  final VoidCallback onJoinRequest;

  const OrganizationCard({
    Key? key,
    required this.organization,
    required this.onTap,
    required this.onFollowToggle,
    required this.onJoinRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 0.5),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: organization.image != null
                    ? NetworkImage(organization.image!)
                    : null,
                child: organization.image == null
                    ? Text(
                        organization.name.isNotEmpty
                            ? organization.name[0]
                            : 'ج',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organization.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      organization.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            organization.isFollowed
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: organization.isFollowed
                                ? Colors.red
                                : Colors.grey,
                            size: 28,
                          ),
                          onPressed: () async {
                            try {
                              await onFollowToggle();
                            } catch (_) {}
                          },
                          tooltip: organization.isFollowed
                              ? 'إلغاء المتابعة'
                              : 'متابعة',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${organization.membersCount ?? 0} عضو',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (!organization.isMember)
                          OutlinedButton(
                            onPressed: onJoinRequest,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B4332),
                              side: const BorderSide(color: Color(0xFF1B4332)),
                            ),
                            child: const Text('طلب انضمام'),
                          ),
                        if (organization.isMember)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'عضو',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
