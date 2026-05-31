import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_solutions/utils/currency_util.dart';

class FileStatusCard extends StatelessWidget {
  final String title;
  final String fileCount;
  final String? amount;
  final Color statusColor;
  final VoidCallback onPress;

  const FileStatusCard(
      {super.key,
      required this.title,
      required this.fileCount,
      this.amount,
      required this.statusColor,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        width: 175.w,
        // margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(11),
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.black54,
                ),
              ],
            ),

            const SizedBox(height: 4),

            // File Count
            Text(
              "$fileCount Files",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 12),

            // Amount
            if (amount != null) ...[
              const SizedBox(height: 12),
              Text(
                '₹${CurrencyUtils.formatAmount(amount.toString())}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
