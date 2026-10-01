# What RESTest is handed

Besides the API's document, its address and the time budget, RESTest is handed whatever this
directory holds. The entry point passes each file it finds with the option of RESTest's
command line named beside it:

| File | Passed as | To |
|---|---|---|
| `plan.yaml` | `--campaign` | every API |
| `settings.yaml` | `--settings` | every API |
| `dictionaries/<API>/` | `--dictionary` | that API alone |

It holds nothing else: this package runs RESTest with its published defaults. The
directory is here because the Dockerfile copies it.

The formats are RESTest's own: [command line](https://github.com/isa-group/RESTest/blob/17369e00f244485680f7bd698fff6b60c8684c66/docs/command-line.md),
[plans](https://github.com/isa-group/RESTest/blob/17369e00f244485680f7bd698fff6b60c8684c66/docs/campaign-format.md),
[settings](https://github.com/isa-group/RESTest/blob/17369e00f244485680f7bd698fff6b60c8684c66/docs/settings.md) and
[dictionaries](https://github.com/isa-group/RESTest/blob/17369e00f244485680f7bd698fff6b60c8684c66/docs/dictionary-format.md).
