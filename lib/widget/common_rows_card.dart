import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_solutions/widget/text_style.dart';

import '../controllers/theme_controller.dart';

class CommonRows {
  /// ================= SINGLE ROW =================
  Widget buildSingleRow(dynamic icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIcon(icon, null),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= DOUBLE ROW =================
  Widget buildDoubleRow({
    required dynamic iconLeft,
    required String valueLeft,
    required dynamic iconRight,
    required String valueRight,
    Color? textColorRight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      child: Row(
        children: [
          /// LEFT SIDE
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(iconLeft, null),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    valueLeft,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// RIGHT SIDE
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(iconRight, null),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    valueRight,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColorRight ?? Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= SINGLE ROW (NO EXPAND) =================
  /// Use this ONLY when parent width is fixed
  Widget buildSingleRowNoExpand(dynamic icon, String value, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        children: [
          if (value.isNotEmpty) _buildIcon(icon, color),
          if (value.isNotEmpty) const SizedBox(width: 6),
          Text(
            value,
            style: AppTextStyle.headerTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// ================= MASK MOBILE =================
  static String mask(String number) {
    if (number.length < 6) return number;
    return "xxxxxx${number.substring(6)}";
  }

  /// ================= ICON BUILDER =================
  Widget _buildIcon(dynamic icon, Color? color) {
    if (icon is String) {
      return SvgPicture.asset(
        icon,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
        color: color ?? Colors.grey[700],
      );
    } else if (icon is IconData) {
      return Icon(icon, size: 20, color: color ?? Colors.grey[700]);
    } else {
      return const SizedBox.shrink();
    }
  }
}
