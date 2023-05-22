///
library repository_url;

import 'dart:collection';

///
abstract interface class RepositoryUrl {
  /// Scheme uses in [RepositoryUrl].
  /// 
  /// The possible returned values are:
  /// 
  /// * http(s)
  /// * git
  /// * ssh
  /// * rsync
  /// 
  /// It returns `null` if using alternative SSH URL.
  String? get scheme;

  /// User information of [RepositoryUrl].
  /// 
  /// It mostly return `git` for getting repository from
  /// public Git hosting website.
  /// 
  /// It may return empty [String] if not applied.
  String get userInfo;

  /// Host of repository.
  String get host;

  /// Port uses for getting repository.
  /// 
  /// It returns `null` for using alternative SSH URL.
  int? get port;

  /// Path to the Git repository from [host]'s root.
  String get path;

  /// Segment of [path].
  List<String> get pathSegment;

  factory RepositoryUrl(String url) {
    final tpuri = Uri.tryParse(url);

    if (tpuri != null) {
      if (!{"http", "https", "git", "ssh", "rsync"}.contains(tpuri.scheme)) {
        throw FormatException(
            "This URL scheme does not uses for resolving remote repository",
            tpuri.scheme);
      }

      return _UriAdapter(tpuri.replace(query: null, fragment: null));
    }

    try {
      final RegExpMatch match = _AltSshUrl.regex.firstMatch(url)!;

      final path = match.group(3);

      return _AltSshUrl(
          match.group(1)!,
          match.group(2)!,
          path == null
              ? const <String>[]
              : UnmodifiableListView(path.split("/")));
    } catch (_) {
      throw FormatException("The given URL can not be resolved", url);
    }
  }

  @override
  String toString();

  @override
  int get hashCode;

  @override
  bool operator ==(Object other);
}

final class _UriAdapter implements RepositoryUrl {
  final Uri uri;

  _UriAdapter(this.uri) : assert(!uri.hasFragment);

  @override
  String get host => uri.host;

  @override
  String get path => uri.path;

  @override
  List<String> get pathSegment => uri.pathSegments;

  @override
  int? get port => uri.port;

  @override
  String? get scheme => uri.scheme;

  @override
  String get userInfo => uri.userInfo;

  @override
  String toString() {
    return "$uri";
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}

final class _AltSshUrl implements RepositoryUrl {
  @override
  final String userInfo;

  @override
  final String host;

  @override
  final List<String> pathSegment;

  @override
  String? get scheme => null;

  @override
  int? get port => null;

  @override
  String get path => ":${pathSegment.join("/")}";

  static final RegExp regex = RegExp(
      r"^([a-zA-Z][-a-zA-Z0-9._]{0,29})@([-a-zA-Z0-9._]{1,256}\.[a-zA-Z0-9()]{1,6}):([-a-zA-Z0-9()_.//]*)$");

  _AltSshUrl(this.userInfo, this.host, this.pathSegment)
      : assert(userInfo.isNotEmpty),
        assert(host.isNotEmpty);

  @override
  String toString() {
    return "$userInfo@$host$path";
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}
