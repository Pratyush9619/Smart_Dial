import 'package:flutter/material.dart';
import '../../models/hrms/leave_status_model.dart';

class LeaveDetailsPage extends StatelessWidget {
  final LeaveData leave;

  const LeaveDetailsPage({
    super.key,
    required this.leave,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(leave.status);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Leave Details",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.leaveType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${leave.startDate}  -  ${leave.endDate}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      leave.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _detailCard(
              title: "Leave Information",
              icon: Icons.info_outline,
              children: [
                _row(
                  Icons.category_outlined,
                  "Leave Type",
                  leave.leaveType,
                ),
                _row(
                  Icons.date_range,
                  "Duration",
                  "${leave.startDate} to ${leave.endDate}",
                ),
                _row(
                  Icons.person_outline,
                  "Employee",
                  leave.employeeName,
                ),
              ],
            ),

            const SizedBox(height: 14),

            _detailCard(
              title: "Reason",
              icon: Icons.message_outlined,
              children: [
                Text(
                  leave.reason.isEmpty ? "-" : leave.reason,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                )
              ],
            ),

            const SizedBox(height: 14),

            _detailCard(
              title: "Approval Details",
              icon: Icons.verified_outlined,
              children: [
                _row(
                  Icons.person,
                  "Approved By",
                  leave.approverName ?? "-",
                ),
                _row(
                  Icons.calendar_month,
                  "Approved Date",
                  leave.approveDate.isEmpty ? "-" : leave.approveDate,
                ),
                _row(
                  Icons.notes,
                  "Remark",
                  leave.remark ?? "-",
                ),
              ],
            ),

            const SizedBox(height: 14),

            _detailCard(
              title: "Request Information",
              icon: Icons.history,
              children: [
                _row(
                  Icons.access_time,
                  "Created At",
                  leave.createdAt,
                ),
                _row(
                  Icons.update,
                  "Action Date",
                  leave.actionDate ?? "-",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;

      case "Rejected":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }
}
