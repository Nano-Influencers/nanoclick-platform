import 'package:click_workers/services/kyc_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final draft = KycDraft.instance;

  setUp(() {
    draft.documentType = null;
    draft.documentUrl = null;
  });

  test('serializes private KYC document metadata', () {
    draft.documentType = 'national_id';
    draft.documentUrl = 'kyc/user-id/document.pdf';

    final json = draft.toJson();

    expect(json['document_type'], 'national_id');
    expect(json['document_url'], 'kyc/user-id/document.pdf');
  });

  test('omits empty optional document metadata', () {
    final json = draft.toJson();

    expect(json.containsKey('document_type'), isFalse);
    expect(json.containsKey('document_url'), isFalse);
  });
}
