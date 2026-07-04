# Quark

A comprehensive docker image to run workers for
[Prefect](https://github.com/PrefectHQ/prefect), with included Python
Playwright and supporting python modules. See `requirements.in` for a list of
included python modules.

Playwright is installed with the [chrome headless
shell](https://developer.chrome.com/blog/chrome-headless-shell).

The `latest` version of this container is not published, pull exact versions
instead. Eg. `docker pull rsubr/quark:26.07`.

Camoufox (a Firefox-based automation engine) is also included. It needs a
display to run against, which the container doesn't have by default. Set the
`ENABLE_VIRTUAL_DISPLAY` environment variable to `true` when running the
container to have it start a virtual display automatically:

```bash
docker run -e ENABLE_VIRTUAL_DISPLAY=true -v ./example.py:/app/example.py rsubr/quark:26.07 python /app/example.py
```

## Docker Compose Example

A typical setup runs a Prefect server (the manager) and one or more Quark
containers (the workers) that poll it for work.

Replace `example.com`, `user` and `password` before using these examples.

### Flowright (manager):

```yaml
# Filename: /srv/flowright.example.com/docker-compose.yaml

name: flowright-example-com

services:
  flowright:
    image: rsubr/quark:26.07
    container_name: flowright.example.com
    hostname: flowright
    restart: always

    command: "prefect server start"

    environment:
      - PREFECT_SERVER_API_HOST=0.0.0.0
      - PREFECT_SERVER_API_AUTH_STRING=user:password

      - PREFECT_API_URL=https://flowright.example.com/api
      - PREFECT_API_AUTH_STRING=user:password

      - PREFECT_SERVER_DATABASE_CONNECTION_URL=postgresql+asyncpg://flowright:password@pgdb:5432/flowright

    depends_on:
      pgdb:
        condition: service_healthy

    healthcheck:
      test: ["CMD", "curl.py", "http://localhost:4200/api/health"]
      interval: 10s
      retries: 3
      start_period: 10s
      timeout: 10s

    labels:
      - com.centurylinklabs.watchtower.enable=true
      - traefik.enable=true
      - traefik.http.routers.flowright.rule=Host(`flowright.example.com`)
      - traefik.http.routers.flowright.tls=true
      - traefik.http.routers.flowright.tls.certresolver=lets-encrypt
      - traefik.http.routers.flowright.service=flowright
      - traefik.http.services.flowright.loadbalancer.server.port=4200

  pgdb:
    image: postgres:17-alpine
    container_name: flowright-postgres.example.com
    hostname: flowright-postgres
    restart: always

    mem_limit: 256M

    environment:
      - POSTGRES_DB=flowright
      - POSTGRES_USER=flowright
      - POSTGRES_PASSWORD=password

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U flowright -d flowright"]
      start_period: 10s
      interval: 30s
      timeout: 5s
      retries: 3

    volumes:
      - ./pg-data:/var/lib/postgresql/data

    labels:
      - com.centurylinklabs.watchtower.enable=true
```

### Quark (worker):

```yaml
# Filename: /srv/quark-1.example.com/docker-compose.yaml

name: quark-1

services:
  quark-1:
    image: rsubr/quark:26.07
    container_name: quark-1.example.com
    hostname: quark-1
    restart: always
    init: true

    environment:
      - PREFECT_API_URL=https://flowright.example.com/api
      - PREFECT_API_AUTH_STRING=user:password

      # Only needed if this worker runs Camoufox-based tasks — it starts
      # the virtual display Camoufox requires. Leave unset for
      # Playwright/Chromium-only workers.
      - ENABLE_VIRTUAL_DISPLAY=true

    # Concurrency limit "-l" to 2 workers and attach to "production" work pool
    command: prefect worker start --with-healthcheck -t process -l 2 -n "quark-1" -p "production"

    healthcheck:
      test: ["CMD", "curl.py", "http://localhost:8080/health"]
      interval: 10s
      retries: 3
      start_period: 10s
      timeout: 10s

    volumes:
      - ./app:/app

    labels:
      - com.centurylinklabs.watchtower.enable=true
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
