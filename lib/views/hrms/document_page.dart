import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smart_solutions/widget/common_form_field.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/document_controller.dart';

class DocumentsPage extends StatelessWidget {
  DocumentsPage({super.key});

  final controller = Get.put(DocumentsController());

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: "Documents",
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            CommonTextFieldWithPrefixIcon(
              label: "Search Text Here",
              controller: SearchController(),
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: "Search Text Here",
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.separated(
                        itemCount: controller.documents.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final doc = controller.documents[index];

                          return DocumentTile(
                            title: doc.title,
                            date: doc.created,
                            svgPath: getFileIcon(doc.name),
                            color: Colors.grey.shade100,
                            onTap: () {
                              // open/download pdf
                              openPdf(doc.downloadUrl);
                            },
                          );
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> openPdf(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      final result = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!result) {
        Get.snackbar(
          "Error",
          "No application found to open PDF",
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
      );
    }
  }
}

String getFileIcon(String fileName) {
  final ext = fileName.split('.').last.toLowerCase();

  switch (ext) {
    case "pdf":
      return "assets/hrms/PDF.svg";

    case "xlsx":
    case "xls":
      return "assets/hrms/XSL.svg";

    case "jpg":
    case "jpeg":
    case "png":
      return "assets/hrms/JPG.svg";

    case "mp4":
      return "assets/hrms/MP4.svg";

    default:
      return "assets/hrms/file.svg";
  }
}

class DocumentTile extends StatelessWidget {
  final String svgPath;
  final String title;
  final String date;
  final Color color;
  final VoidCallback? onTap; // Add this

  const DocumentTile({
    super.key,
    required this.svgPath,
    required this.title,
    required this.date,
    required this.color,
    this.onTap, // Add this
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: SvgPicture.asset(
          svgPath,
          width: 38,
          height: 38,
        ),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      subtitle: Row(
        children: [
          SvgPicture.asset(
            'assets/hrms/calander_date.svg',
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(
              Colors.grey,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            date,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
      ),

      onTap: onTap, // Use here
    );
  }
}
