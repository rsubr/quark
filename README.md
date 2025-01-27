# Quark

A comprehensive docker image to run workers for
[Prefect](https://github.com/PrefectHQ/prefect), with included Python
Playwright and supporting python modules. See `requirements.txt` for a list of
included python modules.

Playwright is installed with the [chrome headless
shell](https://developer.chrome.com/blog/chrome-headless-shell).

The `latest` version of this container are not published, pull exact versions
instead. Eg. `docker pull rsubr/quark:25.01`.

## Updating

1. Manually update `requirements.in` to latest versions.
2. Run `./pip-compile.sh` to generate `./requirements.txt`. Note that docker is required on the local host.
3. Run `git commit` to commit both `requirements.in` and `requirements.txt`.
4. Run `./release.sh` to create a new release, or update a current release.
5. GitHub Actions will take over and build the docker containers and publish it to Docker Hub.
