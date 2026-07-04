# Quark

A comprehensive docker image to run workers for
[Prefect](https://github.com/PrefectHQ/prefect), with included Python
Playwright and supporting python modules. See `requirements.in` for a list of
included python modules.

Playwright is installed with the [chrome headless
shell](https://developer.chrome.com/blog/chrome-headless-shell).

The `latest` version of this container is not published, pull exact versions
instead. Eg. `docker pull rsubr/quark:25.02`.

Camoufox (a Firefox-based automation engine) is also included. It needs a
display to run against, which the container doesn't have by default. Set the
`ENABLE_VIRTUAL_DISPLAY` environment variable to `true` when running the
container to have it start a virtual display automatically:

```bash
docker run -e ENABLE_VIRTUAL_DISPLAY=true -v ./example.py:/app/example.py rsubr/quark:latest python /app/example.py
```

## Updating

1. Manually update `requirements.in` to latest versions.
2. Run `./pip-compile.sh` to generate `./requirements.txt`. Note that docker is required on the local host.
3. Run `git commit` to commit both `requirements.in` and `requirements.txt`.
4. Run `./release.sh` to create a new release, or update a current release.
5. GitHub Actions will take over and build the docker containers and publish it to Docker Hub.

## Windows Build

1. `subst P: c:\temp\python` to create a new drive for the install.
2. Install [Python](https://www.python.org), refer to the [DockerFile](./Dockerfile) for the python version.
3. Install Python in the `P:\Python` path.
4. Create `env.bat` with the following content:

```bat
@rem setup envars for Python and Quark components
set PATH=P:\Python;P:\Python\Scripts;%PATH%
set PLAYWRIGHT_BROWSERS_PATH=P:\Python\pw-browsers
```

5. Run `env.bat` to set the environment variables for the current terminal session.

6. Get [requiremens.in](./requirements.in) and copy it as `P:\Python\requirements.txt`. The `pip-compile.sh` is for Linux and does not work on Windows.

7. Install Python modules, Playwright browsers, and Camoufox:

```bat
pip install -r requirements.txt
playwright install --with-deps chromium
python -m camoufox fetch
```

8. Before invkoing playwright, always run `env.bat` to set the environment variables.
