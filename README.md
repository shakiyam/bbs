bbs
===

[![Lint and Build](https://github.com/shakiyam/bbs/actions/workflows/lint_and_build.yml/badge.svg)](https://github.com/shakiyam/bbs/actions/workflows/lint_and_build.yml)
[![Maintainability](https://qlty.sh/gh/shakiyam/projects/bbs/maintainability.svg)](https://qlty.sh/gh/shakiyam/projects/bbs)
[![Known Vulnerabilities](https://snyk.io/test/github/shakiyam/bbs/badge.svg)](https://snyk.io/test/github/shakiyam/bbs)

Tiny BBS for sample

Technology Stack
----------------

* **Frontend**: Bootstrap 5, Vanilla JavaScript
* **Backend**: Ruby (Sinatra framework)
* **Database**: MySQL 8
* **Deployment**: Docker or Podman with Docker Compose

Requirement
-----------

* Docker or Podman
* Docker Compose

How to run
----------

Run `generate_dotenv.sh` beforehand to create `.env` file.

```console
./generate_dotenv.sh
```

Then run docker compose via `docker-compose-wrapper.sh` to start containers.

```console
./tools/docker-compose-wrapper.sh up -d
```

View at: <http://localhost:4567/>

![screenshot](https://raw.githubusercontent.com/shakiyam/bbs/master/screenshot.png)

Author
------

[Shinichi Akiyama](https://github.com/shakiyam)

License
-------

[MIT License](https://opensource.org/licenses/MIT)
