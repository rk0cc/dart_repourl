import 'package:repository_url/repository_url.dart';
import 'package:test/test.dart';

void main() {
  test("Stringify object", () {
    expect(RepositoryUrl.fromUri(Uri.https("example.com", "bob/project.git")).toString(), "https://example.com/bob/project.git");
    expect(RepositoryUrl.altSsh(
      userInfo: "alice", host: "example.com", path: "sample/projec.git").toString(), "alice@example.com:sample/projec.git");
  });
  group("Parse from string", () {
    test("Uri adapter", () {
      final ua = RepositoryUrl("git://gitdummy.test/kita/concert");
      expect(ua.host, "gitdummy.test");
      expect(ua.path, "/kita/concert");
      expect(ua.userInfo, isEmpty);
      expect(ua.scheme, "git");
      expect(ua.port, 0);
    });
    test("alternative SSH URL", () {
      final asu = RepositoryUrl("git@gitdummy.test:sato/console_sdk");
      expect(asu.host, "gitdummy.test");
      expect(asu.path, ":sato/console_sdk");
      expect(asu.userInfo, "git");
      expect(asu.port, isNull);
      expect(asu.scheme, isNull);
    });
    test("invalid thrown", () {
      expect(() => RepositoryUrl("http://gitdummy.test/agwun/spam.git?updated=86400"), throwsFormatException);
      expect(() => RepositoryUrl("http://gitdummy.test/bgwun/spam.git#secured"), throwsFormatException);
      expect(() => RepositoryUrl(r"C:\\path\to\repo"), throwsFormatException);
      expect(() => RepositoryUrl(r"$HOME\repo"), throwsFormatException);
    });
  });
}
