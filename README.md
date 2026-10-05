# RESTest for RESTgym

[RESTest](https://github.com/isa-group/RESTest) is a black-box testing tool for REST APIs: given
an OpenAPI document and the address of a running API, it generates requests, sends them for as
long as it is given, judges every reply against what the document promised, and reports the
failures it finds. This repository packages it as a tool for
[RESTgym](https://github.com/restgym/restgym), in the shape RESTgym's tool template asks for.

## Which RESTest

| | |
|---|---|
| Version | [2.1.0](https://github.com/isa-group/RESTest/releases/tag/v2.1.0) (tag `v2.1.0`) |
| Commit | [`45cd3dc89753e7e366f67f10b73006c22ed68d53`](https://github.com/isa-group/RESTest/commit/45cd3dc89753e7e366f67f10b73006c22ed68d53) |
| Source code | [isa-group/RESTest at `45cd3dc8`](https://github.com/isa-group/RESTest/tree/45cd3dc89753e7e366f67f10b73006c22ed68d53) |
| Documentation | [README](https://github.com/isa-group/RESTest/blob/45cd3dc89753e7e366f67f10b73006c22ed68d53/README.md) and [command line](https://github.com/isa-group/RESTest/blob/45cd3dc89753e7e366f67f10b73006c22ed68d53/docs/command-line.md) at that commit |
| Configuration | the files in [`config/`](config/README.md) |
| Licence | Apache-2.0, like RESTest |
| Packaged | 2026-10-05 |

The image compiles RESTest from source at that commit; nothing here is a binary.

## Install

The tool's directory under `tools/` must be called **`restest2`**: RESTgym builds a tool's image
with the whole RESTgym checkout as the build context, so the Dockerfile's `COPY` lines name that
path. From the root of a RESTgym checkout, either

```bash
git submodule add https://github.com/isa-group/restest4restgym.git tools/restest2
```

or copy this repository's files into `tools/restest2/`. Then build and run as for any tool:

```bash
./restgym.sh build-images        # option 2, "Build images"
./restgym.sh launch-experiment
./restgym.sh verify-data
```

The build needs network access to GitHub, to fetch RESTest at the commit above, and to Maven
Central, for its dependencies. It takes a few minutes the first time.

## What the image does

It reads the variables RESTgym sets - `API`, `HOST`, `PORT` and `TIME_BUDGET` (minutes) - picks the
API's document from `/specifications` (`<API>.yaml`, or `<API>-openapi.json` when there is no
YAML one), and runs

```bash
restest run /specifications/<API>.yaml --url http://$HOST:$PORT --budget ${TIME_BUDGET}m \
    --out /tmp/restest-out/pass-<n>
```

plus whatever [`config/`](config/README.md) holds. RESTest spends the whole budget; the entry point
keeps the container alive in a loop, as RESTgym expects, should a run end early. It runs on Java 21
and needs no other configuration, credentials or network access beyond the API under test.

To use RESTest itself, without RESTgym, see its [README](https://github.com/isa-group/RESTest/blob/45cd3dc89753e7e366f67f10b73006c22ed68d53/README.md).
