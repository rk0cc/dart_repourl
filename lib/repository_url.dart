/// The one and only libarary for handling Git repository URL.
library repository_url;

import 'dart:collection' show UnmodifiableListView;

/// [Uri]'s replica object that able to recognized common URL
/// structure of Git repository.
abstract final class RepositoryUrl {
  /// Scheme uses in [RepositoryUrl].
  ///
  /// The possible returned values are:
  ///
  /// * http(s)
  /// * git
  /// * ssh
  /// * rsync
  /// * file
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

  /// Host of repository except using file [scheme] which leave
  /// as empty;
  String get host;

  /// Port uses for getting repository.
  ///
  /// It returns `null` for using alternative SSH URL.
  int? get port;

  /// Relative path to the Git repository from [host]'s root.
  String get path;

  /// Segment of [path] which should be immutable [List].
  List<String> get pathSegment;

  /// Parse [RepositoryUrl] from [url] that feature slimilar function of
  /// [Uri.parse].
  ///
  /// If the [url] satisfied [Uri]'s structure, all properties in
  /// [RepositoryUrl] will be referred to [Uri] with exact same name.
  /// When the given [url] is not standard structure of [Uri], it
  /// returns delicated class with [RepositoryUrl] implemented if
  /// featured. Currently, [RepositoryUrl] can resolves alternative
  /// SSH URL (the structure will be liked this: `alice@example.com:project/alpha`)
  /// which failed to recognized by [Uri.parse].
  ///
  /// Any invalid [url] syntax causes [FormatException] thrown.
  ///
  /// #### Notice for applying `file` scheme in [url] :
  ///
  /// The file URL must be an **absolute path** from root directory
  /// with scheme (`file://`) provided at first of the [String].
  /// In additions, always uses slash `/` to divide path no matter which
  /// operation system you uses. Thus, embedding environment variable
  /// into [url] does not resolved when parsing.
  ///
  /// These are examples that can be applied:
  ///
  /// * `file:///C:/foo/bar` (for Windows)
  /// * `file:///home/user/foo/bar` (for UNIX)
  factory RepositoryUrl(String url) {
    final tpuri = Uri.tryParse(url);

    if (tpuri != null) {
      // Uri can be recognized
      return RepositoryUrl.fromUri(tpuri);
    }

    try {
      final List<(RegExp, RepositoryUrl Function(RegExpMatch))> syntaxMatcher =
          [
        // Alternative SSH URL
        (
          _AltSshUrl.regex,
          (match) {
            final path = match.group(3);

            return _AltSshUrl(
                match.group(1)!,
                match.group(2)!,
                path == null
                    ? const <String>[]
                    : UnmodifiableListView(path.split("/")));
          }
        )
      ];

      final smrec =
          syntaxMatcher.singleWhere((element) => element.$1.hasMatch(url));

      return smrec.$2(smrec.$1.firstMatch(url)!);
    } on AssertionError {
      rethrow;
    } catch (_) {
      throw FormatException("The given URL can not be resolved", url);
    }
  }

  /// Get a [RepositoryUrl] from given [uri].
  /// 
  /// [FormatException] will be thrown if:
  /// 
  /// * Applied unsupported [scheme] in [Uri.scheme]
  /// * Contains [Uri.fragment] or [Uri.query]
  /// * [Uri] is not absolute
  factory RepositoryUrl.fromUri(Uri uri) {
    if (!{"http", "https", "git", "ssh", "rsync", "file"}
        .contains(uri.scheme)) {
      throw FormatException(
          "This URL scheme does not uses for resolving repository", uri.scheme);
    } else if (uri.hasFragment || uri.hasQuery) {
      throw FormatException("Repository URL does not allow fragment and query",
          {"fragment": uri.fragment, "query": uri.query});
    } else if (!uri.isAbsolute) {
      throw FormatException("The given URL should be in absolute", uri);
    }

    return _UriAdapter(uri);
  }

  /// Construct [RepositoryUrl] in alternative SSH URL format.
  /// 
  /// [FormatException] thrown if given [path] is invalid.
  factory RepositoryUrl.altSsh(
      {required String userInfo, required String host, String path = ""}) {
    if (!path.contains(RegExp("[-a-zA-Z0-9()_.//]*"))) {
      throw FormatException("Invalid path parsed", path);
    }

    return _AltSshUrl(userInfo, host, UnmodifiableListView(path.split("/")));
  }

  /// Return to corresponded structure of [RepositoryUrl] in [String].
  /// 
  /// If [RepositoryUrl] is created by [RepositoryUrl.new], it should be
  /// returned exact same [String] from parameter.
  @override
  String toString();

  /// Return an [int] hash code form [toString].
  @override
  int get hashCode;

  /// Compare does [other] is exact same of `thia`.
  @override
  bool operator ==(Object other);
}

/// An adapter for [RepositoryUrl] which structure is valid for
/// [Uri].
final class _UriAdapter implements RepositoryUrl {
  final Uri uri;

  _UriAdapter(this.uri)
      : assert(!uri.hasFragment),
        assert(!uri.hasQuery);

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

/// Strcture of alternative SSH URL.
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
  String get path => pathSegment.join("/");

  /// [RegExp] for validating structure of alternative SSH URL.
  static final RegExp regex = RegExp(
      r"^([a-zA-Z][-a-zA-Z0-9._]{0,29})@([-a-zA-Z0-9._]{1,256}\.[a-zA-Z0-9()]{1,6}):([-a-zA-Z0-9()_.//]*)$");

  _AltSshUrl(this.userInfo, this.host, this.pathSegment)
      : assert(userInfo.isNotEmpty),
        assert(host.isNotEmpty);

  @override
  String toString() {
    StringBuffer buf = StringBuffer()
      ..write(userInfo)
      ..write("@")
      ..write(host);

    if (pathSegment.isNotEmpty) {
      buf
        ..write(":")
        ..write(path);
    }

    return buf.toString();
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) {
    return hashCode == other.hashCode;
  }
}
