import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onTap;

  const ProjectCard({Key? key, required this.project, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double progress = project.goal_amount > 0
        ? (project.balance / project.goal_amount).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getArabicStatus(project.status),
                      style: TextStyle(
                        color: _getStatusColor(project.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFFD4AF37),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFinancialItem('المستهدف', '${project.goal_amount.toStringAsFixed(0)} د.ل'),
                  _buildFinancialItem('المجموع', '${project.balance.toStringAsFixed(0)} د.ل'),
                  _buildFinancialItem(
                    'المتبقي',
                    '${(project.goal_amount - project.balance).toStringAsFixed(0)} د.ل',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'active') return Colors.green;
    if (status == 'completed') return Colors.blue;
    return Colors.red;
  }

  String _getArabicStatus(String status) {
    if (status == 'active') return 'نشط';
    if (status == 'completed') return 'مكتمل';
    return 'ملغي';
  }
}