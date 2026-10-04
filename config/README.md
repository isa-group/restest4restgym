# What RESTest is handed

Besides the API's document, its address and the time budget, RESTest is handed whatever this
directory holds. The entry point passes each file it finds with the option of RESTest's
command line named beside it:

| File | Passed as | To |
|---|---|---|
| `plan.yaml` | `--campaign` | every API |
| `settings.yaml` | `--settings` | every API |
| `dictionaries/<API>/` | `--dictionary` | that API alone |

This package holds:

- `dictionaries/flight-search/values.yaml`
- `dictionaries/gestao-hospital/values.yaml`
- `dictionaries/kafka-rest-proxy/values.yaml`
- `dictionaries/notebook-manager/values.yaml`
- `dictionaries/pet-clinic/values.yaml`
- `plan.yaml`

The formats are RESTest's own: [command line](https://github.com/isa-group/RESTest/blob/f1e99896a602a2611c7004949b34a7b639ba8b73/docs/command-line.md),
[plans](https://github.com/isa-group/RESTest/blob/f1e99896a602a2611c7004949b34a7b639ba8b73/docs/campaign-format.md),
[settings](https://github.com/isa-group/RESTest/blob/f1e99896a602a2611c7004949b34a7b639ba8b73/docs/settings.md) and
[dictionaries](https://github.com/isa-group/RESTest/blob/f1e99896a602a2611c7004949b34a7b639ba8b73/docs/dictionary-format.md).
