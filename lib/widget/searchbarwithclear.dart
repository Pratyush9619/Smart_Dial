import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:smart_solutions/controllers/common_filter_controller.dart';
import 'package:smart_solutions/theme/app_theme.dart';

import '../controllers/theme_controller.dart';

class SearchBarWithClear extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;
  final TextInputType textInputType;
  final FocusNode? focusNode;
  final ValueChanged<DateTimeRange?>? onDateRangeSelected;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? dateHintText;
  final bool showDatePickerIcon;
  final String hintText;

  const SearchBarWithClear({
    Key? key,
    required this.controller,
    required this.onClear,
    required this.onChanged,
    this.textInputType = TextInputType.text,
    this.focusNode,
    this.onDateRangeSelected,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.dateHintText = 'Selected Date',
    this.showDatePickerIcon = true,
    this.hintText = 'Search Text Here',
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchBarWithClearState createState() => _SearchBarWithClearState();
}

class _SearchBarWithClearState extends State<SearchBarWithClear> {
  final FocusNode _internalFocusNode = FocusNode();

  final CommonFilterController _commonFilterController =
      Get.find<CommonFilterController>();

  final ThemeController _themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showDatePicker() async {
    final FocusNode focusNode = widget.focusNode ?? _internalFocusNode;
    focusNode.unfocus();

    final DateTimeRange? pickedRange = await showDateRangePicker(
        context: context,
        firstDate: widget.firstDate ?? DateTime(2000),
        lastDate: widget.lastDate ?? DateTime(2100),
        initialDateRange: null);

    if (pickedRange != null) {
      _commonFilterController.setSelectedDate(
          pickedRange.start, pickedRange.end);

      widget.onDateRangeSelected?.call(pickedRange);
    }
  }

  void _clearDate() {
    _commonFilterController.clearDateFilter();
    _commonFilterController.selectedRange.value = null;

    widget.onDateRangeSelected?.call(null);
  }

  void _clearSearchText() {
    widget.controller.clear();
    widget.onChanged('');
    final FocusNode focusNode = widget.focusNode ?? _internalFocusNode;
    focusNode.requestFocus();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final FocusNode focusNode = widget.focusNode ?? _internalFocusNode;
    final hasSearchText = widget.controller.text.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        children: [
          Expanded(
            child: Obx(() {
              final isSelected =
                  _commonFilterController.isDateRangeSelected.value;
              final primaryColor = _themeController.primaryColor.value;

              return SizedBox(
                height: 40,
                child: isSelected
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  _commonFilterController.selectedRange.value !=
                                          null
                                      ? "${_formatDate(_commonFilterController.selectedRange.value!.start)} - "
                                          "${_formatDate(_commonFilterController.selectedRange.value!.end)}"
                                      : widget.dateHintText!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _clearDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : TextField(
                        controller: widget.controller,
                        focusNode: focusNode,
                        onChanged: widget.onChanged,
                        keyboardType: widget.textInputType,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                          ),
                          suffixIcon: hasSearchText
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Animated clear button
                                      AnimatedOpacity(
                                        opacity: hasSearchText ? 1.0 : 0.0,
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: IconButton(
                                          onPressed: _clearSearchText,
                                          icon: Icon(
                                            Icons.cancel,
                                            color: Colors.grey.shade600,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(
                                            minWidth: 36,
                                            minHeight: 36,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.blueColor,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
              );
            }),
          ),
          if (widget.showDatePickerIcon) ...[
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _commonFilterController.isDateRangeSelected.value
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade400,
                    width: 1,
                  ),
                  color: _commonFilterController.isDateRangeSelected.value
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : Colors.transparent,
                  boxShadow: _commonFilterController.isDateRangeSelected.value
                      ? [
                          BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.calendar_month,
                  size: 22.sp,
                  color: _commonFilterController.isDateRangeSelected.value
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
