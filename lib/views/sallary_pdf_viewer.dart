import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_solutions/controllers/sallary_slip_controller.dart';
import 'package:smart_solutions/widget/common_scaffold.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SalarySlipPdfPage extends StatefulWidget {
  final String month;
  const SalarySlipPdfPage({super.key, required this.month});

  @override
  State<SalarySlipPdfPage> createState() => _SalarySlipPdfPageState();
}

class _SalarySlipPdfPageState extends State<SalarySlipPdfPage> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    // For demo, copy a PDF from assets to temp folder.
    final bytes = await DefaultAssetBundle.of(context)
        .load('assets/salary_slip_sample.pdf');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${widget.month}.pdf');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    setState(() => pdfPath = file.path);
  }

  void _sharePdf() {
    if (pdfPath != null) {
      final file = XFile(pdfPath!);
      Share.shareXFiles(
        [file],
        text: "Salary Slip - ${widget.month}",
      );
    }
  }

  void _downloadPdf() async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/${widget.month}.pdf');
    await File(pdfPath!).copy(dest.path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Downloaded to ${dest.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SallarySlipController());
    final url = controller.salarySlipUrl.value;
    return CommonScaffold(
      title: "Salary Slip - ${widget.month}",
      actions: [
        IconButton(
          icon: const Icon(
            Icons.download,
            color: Colors.white,
          ),
          onPressed: _downloadPdf,
        ),
        IconButton(
          icon: const Icon(
            Icons.share,
            color: Colors.white,
          ),
          onPressed: _sharePdf,
        ),
      ],
      body: pdfPath == null
          ? const Center(child: CircularProgressIndicator())
          : SfPdfViewer.network(url),
    );
  }
}
