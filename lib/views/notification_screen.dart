import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_solutions/controllers/notification_controller.dart';
import 'package:smart_solutions/theme/app_theme.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:smart_solutions/widget/loading_page.dart';
import 'package:smart_solutions/widget/no_data_available.dart';

import '../controllers/theme_controller.dart';

class NotificationSCreen extends StatefulWidget {
  const NotificationSCreen({super.key});

  @override
  State<NotificationSCreen> createState() => _NotificationSCreenState();
}

class _NotificationSCreenState extends State<NotificationSCreen> {
  final NotificationController notificationController =
      Get.find<NotificationController>();

  final ThemeController themeController = Get.find<ThemeController>();

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!notificationController.notificationMoreLoading.value &&
            notificationController.notificationHasMore.value) {
          notificationController.getNotificationList(loadMore: true);
        }
      }
    });

    /// ⭐ first load
    notificationController.markAllAsRead();
    notificationController.getNotificationList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        title: 'Notifications',
        showBack: true,
        body: Obx(() {
          final list = notificationController.notificationData;

          if (notificationController.isLoading.value && list.isEmpty) {
            return const Center(child: LoadingPage());
          }

          if (list.isEmpty) {
            return const NoDataAvailable();
          }

          return ListView.builder(
            itemCount: list.length + 1,
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (index == list.length) {
                if (notificationController.notificationMoreLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!notificationController.notificationHasMore.value) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "No more notifications",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return const SizedBox();
              }

              final item = list[index];

              DateTime parsedDate =
                  DateTime.tryParse(item['created'] ?? '') ?? DateTime.now();

              String date =
                  DateFormat('dd MMM yyyy hh:mm:ss a').format(parsedDate);

              return showNotificationData(
                date,
                item['title'] ?? '',
                item['status'] ?? '',
                item['message'] ?? '',
                item['is_read'] == '1',
              );
            },
          );
        }));
    // body: Obx(() {
    //   if (notificationController.isLoading.value &&
    //       notificationController.notificationData.isEmpty) {
    //     return const Center(child: LoadingPage());
    //   }

    //   if (notificationController.notificationData.isEmpty) {
    //     return const NoDataAvailable();
    //   }

    //   return ListView.builder(
    //     itemCount: notificationController.notificationData.length,
    //     itemBuilder: (context, index) {
    //       DateTime parsedDate = DateTime.parse(
    //           notificationController.notificationData[index]['created']);
    //       String date =
    //           DateFormat('dd MMM yyyy hh:mm:ss a').format(parsedDate);

    //       return showNotificationData(
    //           date,
    //           notificationController.notificationData[index]['title'] ?? '',
    //           notificationController.notificationData[index]['status'] ??
    //               '',
    //           notificationController.notificationData[index]['message'] ??
    //               '');
    //     },
    //   );
    // }));
  }

  // showNotificationData(
  //     String date, String fileStatus, String status, String msg) {
  //   return Card(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     elevation: 4,
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 date,
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16.sp,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 6),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 fileStatus, // Date
  //                 style: TextStyle(
  //                   color: AppColors.secondayColor,
  //                   fontSize: 14.sp,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 status,
  //                 style: TextStyle(
  //                   color: AppColors.secondayColor,
  //                   fontSize: 14.sp,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 6),
  //           Text(
  //             msg,
  //             style: TextStyle(
  //               color: AppColors.secondayColor,
  //               fontSize: 14.sp, // Responsive font size
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget showNotificationData(
    String date,
    String title,
    String status,
    String msg,
    bool isRead,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isRead ? Colors.white : const Color(0xffF4F8FF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          //   decoration: BoxDecoration(
          //     color: Colors.green.withOpacity(.1),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Text(
          //     status,
          //     style: TextStyle(
          //       fontSize: 11,
          //       color: Colors.green.shade700,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  size: 16,
                  color: themeController.primaryColor.value,
                ),
              ),

              const SizedBox(width: 8),

              /// TITLE
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: null,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isRead ? FontWeight.w500 : FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),

                        /// 📅 DATE
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),

                    /// 🟢 STATUS
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 10, vertical: 4),
                    //   decoration: BoxDecoration(
                    //     color: Colors.green.withOpacity(.1),
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Text(
                    //     status,
                    //     style: TextStyle(
                    //       fontSize: 11,
                    //       color: Colors.green.shade700,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              /// 🔴 UNREAD DOT
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          /// 📝 MESSAGE
          Text(
            msg,
            softWrap: true,
            maxLines: null,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.black54,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
                icon: const Icon(Icons.copy, size: 18),
                color: themeController.primaryColor.value,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: msg));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                }),
          )
        ],
      ),
    );
  }

  // Widget showNotificationData(
  //   String date,
  //   String title,
  //   String status,
  //   String msg,
  //   bool isRead,
  // ) {
  //   return AnimatedContainer(
  //     duration: const Duration(milliseconds: 300),
  //     margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(18),
  //       color: isRead ? Colors.white : const Color(0xffF4F8FF),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(.06),
  //           blurRadius: 12,
  //           offset: const Offset(0, 6),
  //         )
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(5.0),
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //             decoration: BoxDecoration(
  //               color: AppColors.primaryColor.withOpacity(.08),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Text(
  //               date,
  //               style: const TextStyle(
  //                 fontSize: 11,
  //                 fontWeight: FontWeight.w600,
  //                 color: AppColors.primaryColor,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Row(
  //           children: [
  //             /// ⭐ LEFT STATUS STRIP
  //             Container(
  //               width: 5,
  //               height: 110,
  //               decoration: BoxDecoration(
  //                 borderRadius: const BorderRadius.only(
  //                   topLeft: Radius.circular(18),
  //                   bottomLeft: Radius.circular(18),
  //                 ),
  //                 gradient: LinearGradient(
  //                   colors: isRead
  //                       ? [Colors.grey.shade300, Colors.grey.shade200]
  //                       : [
  //                           AppColors.primaryColor,
  //                           AppColors.primaryColor.withOpacity(.6)
  //                         ],
  //                   begin: Alignment.topCenter,
  //                   end: Alignment.bottomCenter,
  //                 ),
  //               ),
  //             ),

  //             /// ⭐ MAIN CONTENT
  //             Expanded(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(14),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     /// TOP ROW
  //                     Row(
  //                       children: [
  //                         const Icon(Icons.notifications_active,
  //                             size: 20, color: AppColors.primaryColor),
  //                         const SizedBox(width: 6),
  //                         Expanded(
  //                           child: Text(
  //                             title,
  //                             maxLines: null,
  //                             overflow: TextOverflow.ellipsis,
  //                             style: TextStyle(
  //                               fontSize: 15,
  //                               fontWeight:
  //                                   isRead ? FontWeight.w500 : FontWeight.w700,
  //                               color: Colors.black87,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),

  //                     const SizedBox(height: 10),

  //                     /// STATUS CHIP
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 10, vertical: 5),
  //                       decoration: BoxDecoration(
  //                         color: Colors.green.withOpacity(.08),
  //                         borderRadius: BorderRadius.circular(20),
  //                       ),
  //                       child: Text(
  //                         status,
  //                         maxLines: null,
  //                         style: TextStyle(
  //                           fontSize: 12,
  //                           color: Colors.green.shade700,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ),

  //                     const SizedBox(height: 10),

  //                     /// MESSAGE
  //                     Text(
  //                       msg,
  //                       maxLines: null,
  //                       style: const TextStyle(
  //                         height: 1.4,
  //                         fontSize: 13,
  //                         color: Colors.black54,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             )
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget showNotificationData(
  //     String date, String fileStatus, String status, String msg) {
  //   return Card(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     elevation: 6,
  //     shadowColor: Colors.black26,
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // TOP STRIP
  //         Container(
  //           decoration: BoxDecoration(
  //             borderRadius: const BorderRadius.only(
  //               topLeft: Radius.circular(16),
  //               topRight: Radius.circular(16),
  //             ),
  //             gradient: LinearGradient(
  //               colors: [
  //                 AppColors.primaryColor.withOpacity(0.9),
  //                 AppColors.primaryColor.withOpacity(0.6),
  //               ],
  //             ),
  //           ),
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Icon(Icons.notifications, color: Colors.white, size: 20),
  //               Text(
  //                 date,
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.w600,
  //                   fontSize: 14,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         // MAIN CONTENT
  //         Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Column(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       const Icon(Icons.folder,
  //                           color: AppColors.primaryColor, size: 20),
  //                       const SizedBox(width: 6),
  //                       SizedBox(
  //                         child: Text(
  //                           fileStatus,
  //                           overflow: TextOverflow.ellipsis,
  //                           style: const TextStyle(
  //                             color: AppColors.primaryColor,
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w600,
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Icon(Icons.check_circle,
  //                           color: Colors.green.shade600, size: 20),
  //                       const SizedBox(width: 6),
  //                       Text(
  //                         status,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: TextStyle(
  //                           color: Colors.green.shade700,
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 12),
  //               Text(
  //                 msg,
  //                 style: const TextStyle(
  //                   color: Colors.black87,
  //                   fontSize: 14,
  //                   height: 1.4,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
