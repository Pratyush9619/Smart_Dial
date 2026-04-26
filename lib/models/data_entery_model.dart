import 'package:flutter/material.dart';

class DataEntryModel {
  List<Data>? data;

  DataEntryModel({this.data});

  // Factory constructor for JSON parsing
  factory DataEntryModel.fromJson(Map<String, dynamic> json) {
    return DataEntryModel(
      data: json['data'] != null
          ? List<Data>.from(json['data'].map((v) => Data.fromJson(v)))
          : null,
    );
  }

  // Convert object to JSON map
  Map<String, dynamic> toJson() {
    return {
      if (data != null) 'data': data!.map((v) => v.toJson()).toList(),
    };
  }
}

class Data {
  String? id;
  String? subAdminId;
  String? dashboardType;
  String? dsaName;
  String? date;
  String? mobileNo;
  String? customerName;
  String? customerId;
  String? income; // Changed to int for calculation purposes
  String? companyName;
  String? caseType;
  String? caseStudy;
  String? dob;
  String? disbursementDate;
  double? loanAmount; // Changed to double for precision in financial data
  String? loginBank;

  String? bankerId;
  String? bankerName;
  String? bankerMobile;
  String? bankerEmail;
  String? losNo;
  String? teleCallerName;
  String? teleCallerId;
  String? teamLeader;
  String? productType;
  String? sourcing;
  String? status;
  String? balanceTransfer;
  String? demandDraftstatus;
  String? demandraftRemark;
  String? comments;
  List<CommentData>? commentData;
  String? invoiceId;
  String? paidStatus;
  String? tcName;
  String? tlName;
  String? adminSubAdminName;
  String? calculationId;
  String? invoiceNumber;
  String? bankName;
  String? dataStatus;
  String? dataEntryStatus;

  // Constructor with named parameters
  Data({
    this.id,
    this.subAdminId,
    this.dashboardType,
    this.dsaName,
    this.date,
    this.mobileNo,
    this.customerName,
    this.customerId,
    this.income,
    this.companyName,
    this.caseType,
    this.caseStudy,
    this.dob,
    this.disbursementDate,
    this.loanAmount,
    this.loginBank,
    this.bankerId,
    this.bankerName,
    this.bankerMobile,
    this.bankerEmail,
    this.losNo,
    this.teleCallerName,
    this.teleCallerId,
    this.teamLeader,
    this.productType,
    this.sourcing,
    this.status,
    this.balanceTransfer,
    this.demandDraftstatus,
    this.demandraftRemark,
    this.comments,
    this.commentData,
    this.invoiceId,
    this.paidStatus,
    this.tcName,
    this.tlName,
    this.adminSubAdminName,
    this.calculationId,
    this.invoiceNumber,
    this.bankName,
    this.dataStatus,
    this.dataEntryStatus,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      subAdminId: json['sub_admin_id'],
      dashboardType: json['dashboard_type'],
      dsaName: json['dsaName'] ?? json['dsa_name'],
      date: json['date'],
      mobileNo: json['mobile_no'],
      customerName: json['customer_name'],
      customerId: json['customer_id'],
      income: json['income'] ?? '0', // Safely parse income
      companyName: json['company_name'],
      caseType: json['caseType'],
      caseStudy: json['case_study'],
      dob: json['dob'],
      disbursementDate: json['disbursement_date'],
      loanAmount: double.tryParse(
          json['loanAmount'] ?? '0'), // Safely parse loan amount
      loginBank: json['loginBank'],
      bankerId: json['bankerid'],
      bankerName: json['bankerName'],
      bankerMobile: json['bankerMobile'],
      bankerEmail: json['bankerEmail'],
      losNo: json['losNo'],
      teleCallerName: json['teleCallerName'],
      teleCallerId: json['teleCallerid'],
      teamLeader: json['teamLeader'],
      productType: json['product_type'],
      sourcing: json['sourcing'],
      status: json['status'],
      balanceTransfer: json['balancetransfer'],
      demandDraftstatus: json['demand_draft_status'],
      demandraftRemark: json['demand_draft_remark'],
      comments: json['comment_data'],
      commentData: json['comment_alldata'] != null
          ? List<CommentData>.from(
              json['comment_alldata'].map((v) => CommentData.fromJson(v)))
          : [],
      invoiceId: json['invoice_id'],
      paidStatus: json['paid_status'],
      tcName: json['tcname'],
      tlName: json['tlname'],
      adminSubAdminName: json['admin_subadmin_name'],
      calculationId: json['calculationid'],
      invoiceNumber: json['invoice_number'],
      bankName: json['bank_name'],
      dataStatus: json['data_status_text'],
      dataEntryStatus: json['data_entry_status'],
    );
  }

  // Convert object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sub_admin_id': subAdminId,
      'dashboard_type': dashboardType,
      'dsaName': dsaName,
      'date': date,
      'mobile_no': mobileNo,
      'customer_name': customerName,
      'customer_id': customerId,
      'income':
          income?.toString(), // Store as string to avoid data loss in JSON
      'company_name': companyName,
      'caseType': caseType,
      'case_study': caseStudy,
      'dob': dob,
      'disbursement_date': disbursementDate,
      'loanAmount': loanAmount?.toString(), // Store as string for precision
      'loginBank': loginBank,
      'bankerid': bankerId,
      'bankerName': bankerName,
      'bankerMobile': bankerMobile,
      'bankerEmail': bankerEmail,
      'losNo': losNo,
      'teleCallerName': teleCallerName,
      'teleCallerid': teleCallerId,
      'teamLeader': teamLeader,
      'product_type': productType,
      'sourcing': sourcing,
      'status': status,
      'comment_data': comments,
      'comment_alldata': commentData, // Convert comment data to JSON
      'invoice_id': invoiceId,
      'paid_status': paidStatus,
      'tcname': tcName,
      'tlname': tlName,
      'admin_subadmin_name': adminSubAdminName,
      'calculationid': calculationId,
      'invoice_number': invoiceNumber,
      'bank_name': bankName,
      'data_status_text': dataStatus,
      'data_entry_status': dataEntryStatus,
    };
  }
}

class CommentData {
  String? id;
  String? dataEntryId;
  String? commentStatus;
  String? userId;
  String? comment;
  String? date;
  String? name;

  bool isLocal;

  /// ✅ REQUIRED for editable list items
  final TextEditingController controller;
  final FocusNode focusNode;

  CommentData({
    this.id,
    this.dataEntryId,
    this.commentStatus,
    this.userId,
    this.comment,
    this.date,
    this.name,
    this.isLocal = false,
  })  : controller = TextEditingController(text: comment ?? ''),
        focusNode = FocusNode();

  factory CommentData.fromJson(Map<String, dynamic> json) {
    return CommentData(
      id: json['id']?.toString(),
      dataEntryId: json['data_entry_id']?.toString(),
      commentStatus: json['comment_status']?.toString(),
      userId: json['user_id']?.toString(),
      comment: json['comment']?.toString(),
      date: json['date']?.toString(),
      name: json['name']?.toString(),
      isLocal: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_entry_id': dataEntryId,
      'comment_status': commentStatus,
      'user_id': userId,
      'comment': comment,
      'date': date,
      'name': name,
    };
  }

  /// ✅ IMPORTANT: cleanup
  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}
