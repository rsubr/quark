# Quark

A comprehensive docker image to run workers for
[Prefect](https://github.com/PrefectHQ/prefect), with included Python
Playwright and supporting python modules. See `requirements.txt` for a list of
included python modules.

Playwright is installed with the [chrome headless
shell](https://developer.chrome.com/blog/chrome-headless-shell).

The `latest` version of this container are not published, pull exact versions
instead. Eg. `docker pull rsubr/quark:25.01`.
