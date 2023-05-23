import 'package:repository_url/repository_url.dart';

void main() {
  // Build from Uri
  final RepositoryUrl uriRepo =
      RepositoryUrl.fromUri(Uri.https("example.com", "bob/project.git"));

  // Construct alternative SSH URL
  final RepositoryUrl asObj = RepositoryUrl.altSsh(
      userInfo: "alice", host: "example.com", path: "sample/projec.git");

  print(uriRepo);
  print(asObj);
}
