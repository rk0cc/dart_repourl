## 1.1.1

* Fix verification in alternative SSH factory.

## 1.1.0

* Change condition of Git alternative SSH:
    * Factory method `RepositoryUrl.altSsh`'s parameter `path` becomes required
    * `(userinfo)@(host)` will be handled by built-in `Uri`. However, it still throw `FormatException` since it does not contains scheme.

## 1.0.0

* Initial release
