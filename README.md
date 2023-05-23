# Alternative `Uri` object for handling Git repository URL format

<p align="center">
    <a href="https://pub.dev/packages/repository_url"><img src="https://img.shields.io/pub/v/repository_url?color=%2333FF33&label=Latest%20version%3A&style=flat-square" alt="Pub version"/></a>
    <a href="https://github.com/sponsors/rk0cc"><img alt="GitHub Sponsors" src="https://img.shields.io/github/sponsors/rk0cc?color=%2333FF33&style=flat-square"></a>
    <a href="https://github.com/rk0cc/dart_repourl/actions/workflows/dart.yml"><img alt="Unit test" src="https://github.com/rk0cc/dart_repourl/actions/workflows/dart.yml/badge.svg"/></a>
</p>

There are various format of URL can be applied for fetching Git repository.
However, not every format can be simply handled by `Uri.parse` in Dart.
For example, it is possible to parse `https://git-example.com/alice/sample_text.git`
but not `git@git-example.com:alice/sample_text.git`.

```dart
// That works
final Uri httpsGit = Uri.parse("https://git-example.com/alice/sample_text.git");

// FormatException
final Uri altSsh = Uri.parse("git@git-example.com:alice/sample_text.git");
```

As a result, `RepositoryUrl` should be used rather than `Uri` which able to resolve URL that `Uri.parse` can't:

```dart
// Both worked
final RepositoryUrl httpRepo = RepositoryUrl("https://git-example.com/alice/sample_text.git");
final RepositoryUrl altSshRepo = RepositoryUrl("git@git-example.com:alice/sample_text.git");
```

More usage can be found in [example](example/main.dart);

## License

BSD-3
