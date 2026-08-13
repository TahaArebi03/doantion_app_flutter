import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:donation_app/services/member_service.dart';

void main() {
  group('MemberService.inviteMember', () {
    test('sends an invitation instead of adding the member directly', () async {
      http.Request? capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        return http.Response('{"message":"ok"}', 201);
      });

      final service = MemberService('token', client: client);
      await service.inviteMember(42, 'member', organizationId: 7);

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.method, 'POST');
      expect(
        capturedRequest!.url.toString(),
        'http://127.0.0.1:8000/api/member/invitations',
      );
      expect(capturedRequest!.headers['Authorization'], 'Bearer token');
      expect(capturedRequest!.body, contains('"user_id":42'));
      expect(capturedRequest!.body, contains('"role":"member"'));
      expect(capturedRequest!.body, contains('"organization_id":7'));
    });
  });
}
