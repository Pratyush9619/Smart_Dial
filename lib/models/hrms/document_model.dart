class DocumentModel {
  final String id;
  final String title;
  final String name;
  final String created;
  final String downloadUrl;
  final String docName;

  DocumentModel({
    required this.id,
    required this.title,
    required this.name,
    required this.created,
    required this.downloadUrl,
    required this.docName,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      name: json['name'] ?? '',
      created: json['created'] ?? '',
      downloadUrl: json['download_url'] ?? '',
      docName: json['doc_name'] ?? '',
    );
  }
}
