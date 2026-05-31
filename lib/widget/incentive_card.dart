import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/models/incentive_model.dart';
import 'package:smart_solutions/views/spacing_constants.dart';
import 'package:smart_solutions/widget/text_style.dart';

class IncentiveCard extends StatelessWidget {
  final String title;
  final String? duration;
  final Color statusColor;
  final List<IncentiveItem> items;
  final bool isNextPage;
  final VoidCallback? onTap;
  final Widget? footer;

  const IncentiveCard(
      {super.key,
      required this.title,
      this.duration,
      required this.statusColor,
      required this.items,
      this.isNextPage = false,
      this.onTap,
      this.footer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (duration != null)
                      Obx(
                        () => Text(duration!,
                            style: AppTextColor.primaryText(15)),
                      ),
                    kHorizontalSpace(15.w),
                    if (isNextPage)
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.black45,
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ================= INFO ROW =================
            Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: _buildInfoItem(
                            item.label,
                            item.value,
                          ),
                        ),
                      ),
                      if (!isLast) _divider(),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (footer != null) ...[
              const SizedBox(height: 6),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

// ================= INFO ITEM =================
Widget _buildInfoItem(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    ],
  );
}

// ================= DIVIDER =================
Widget _divider() {
  return Container(
    height: 28,
    width: 1,
    color: Colors.grey.withOpacity(0.3),
  );
}
