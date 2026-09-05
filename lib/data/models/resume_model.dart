/// Represents candidate resume metadata stored in private, non-public cloud buckets.
/// Raw public URLs are strictly never exposed; access is governed via cryptographic
/// short-lived signed URLs generated on-demand by the backend.
class ResumeModel {
  final String id;
  final String fileName;
  final int fileSizeBytes;
  final String formattedSize;
  final DateTime uploadedAt;
  final bool isEncrypted;
  final String encryptionAlgorithm;
  final String sha256Checksum;
  final String accessScope;
  final int pageCount;
  final String candidateName;
  final List<String> extractedSkills;

  const ResumeModel({
    required this.id,
    required this.fileName,
    required this.fileSizeBytes,
    required this.formattedSize,
    required this.uploadedAt,
    this.isEncrypted = true,
    this.encryptionAlgorithm = 'AES-256-GCM',
    required this.sha256Checksum,
    this.accessScope = 'private_signed_url_only',
    this.pageCount = 2,
    required this.candidateName,
    this.extractedSkills = const [],
  });

  factory ResumeModel.demo({
    String? name,
    String? fileName,
  }) {
    return ResumeModel(
      id: 'res_sec_${DateTime.now().millisecondsSinceEpoch}',
      fileName: fileName ?? 'Mowli_Kumar_Software_Engineer_CV.pdf',
      fileSizeBytes: 1474560, // ~1.4 MB
      formattedSize: '1.4 MB',
      uploadedAt: DateTime(2026, 9, 1),
      isEncrypted: true,
      encryptionAlgorithm: 'AES-256-GCM (Google Cloud KMS)',
      sha256Checksum: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      accessScope: 'private_signed_url_only',
      pageCount: 2,
      candidateName: name ?? 'Mowli Kumar',
      extractedSkills: const [
        'Flutter',
        'Dart',
        'Python',
        'Cybersecurity',
        'AWS',
        'SQL',
        'Linux',
        'REST APIs',
      ],
    );
  }

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      id: json['id'] as String? ?? 'res_${DateTime.now().millisecondsSinceEpoch}',
      fileName: json['fileName'] as String? ?? 'Resume.pdf',
      fileSizeBytes: json['fileSizeBytes'] as int? ?? 1024000,
      formattedSize: json['formattedSize'] as String? ?? '1.0 MB',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isEncrypted: json['isEncrypted'] as bool? ?? true,
      encryptionAlgorithm: json['encryptionAlgorithm'] as String? ?? 'AES-256-GCM',
      sha256Checksum: json['sha256Checksum'] as String? ?? '',
      accessScope: json['accessScope'] as String? ?? 'private_signed_url_only',
      pageCount: json['pageCount'] as int? ?? 1,
      candidateName: json['candidateName'] as String? ?? '',
      extractedSkills: (json['extractedSkills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'formattedSize': formattedSize,
      'uploadedAt': uploadedAt.toIso8601String(),
      'isEncrypted': isEncrypted,
      'encryptionAlgorithm': encryptionAlgorithm,
      'sha256Checksum': sha256Checksum,
      'accessScope': accessScope,
      'pageCount': pageCount,
      'candidateName': candidateName,
      'extractedSkills': extractedSkills,
    };
  }
}

/// Model for presigned binary upload request response
class PresignedUploadResponse {
  final String uploadUrl;
  final String storageKey;
  final DateTime expiresAt;
  final Map<String, String> requiredHeaders;

  const PresignedUploadResponse({
    required this.uploadUrl,
    required this.storageKey,
    required this.expiresAt,
    required this.requiredHeaders,
  });
}

/// Model for short-lived, authenticated signed download URL response
class SignedDownloadResponse {
  final String signedUrl;
  final DateTime expiresAt;
  final int validitySeconds;

  const SignedDownloadResponse({
    required this.signedUrl,
    required this.expiresAt,
    this.validitySeconds = 900, // 15 minutes default
  });
}
