# Loams Ruby examples

These examples target the published **Loams SDK 0.1.2** release.

[Loams](https://loams.dev) is an open-source engine for hybrid search (vector, BM25 and filters) and SQL over collections of documents. This repository has runnable Ruby examples for the Loams Ruby SDK (gem `loams`, source in [ostrium-labs/loams `sdks/ruby`](https://github.com/ostrium-labs/loams/tree/main/sdks/ruby)).

## Install

```sh
bundle install
```

The `Gemfile` pins the RubyGems package to `loams` 0.1.2. Needs Ruby 3.1 or newer; run `bundle install` to install it.

## What the SDK covers

The examples use the SDK's namespaces, collections, documents, search, vector, graph, SQL and streams modules. `examples/quickstart` demonstrates those modules together; SQL uses parameterized SDK calls, and the notes CLI uses collection handles and search builders. Engine requests no longer use a raw HTTP helper.

## Run against a local engine

Start an engine (see the [0.1.2 release notes](https://github.com/ostrium-labs/loams/blob/v0.1.2/docs/release/preview.md) for the Compose stack):

```sh
cargo run --release -p loams -- dev
```

Point the examples at it. Set `LOAMS_ENDPOINT`; `LOAMS_NAMESPACE` defaults to `examples-ruby`. Set `LOAMS_API_KEY` or `LOAMS_TOKEN` if auth is on:

```sh
export LOAMS_ENDPOINT=http://127.0.0.1:8080   # the default `loams dev` port
bundle exec ruby examples/quickstart/quickstart.rb
bundle exec ruby examples/quickstart/quickstart.rb --live-admin  # optional, read-only
bundle exec ruby examples/sql/sql.rb
bundle exec ruby examples/notes-cli/notes.rb search refund --tenant acme
```

Use a disposable namespace: the examples create collections and append stream records.

| Example | What it shows |
|---|---|
| [quickstart](examples/quickstart) | namespaces, collections, documents, text/vector/hybrid search, experimental graph, SQL, streams |
| [sql](examples/sql) | SDK SQL module with parameters, aggregates, and hybrid retrieval functions |
| [notes-cli](examples/notes-cli) | SDK-backed add/search/count notes CLI |

Docs: <https://loams.dev/docs>. Loams 0.1.2 is preview software and its APIs can change.

Licensed under Apache-2.0 (see `LICENSE`).

## SDK module coverage

| Module family | Example coverage in SDK 0.1.2 |
|---|---|
| `instance` | Covered by quickstart API-version discovery. |
| `namespaces`, `collections`, `documents`, `search`, `vector`, `graph`, `sql`, `streams` | Covered by the quickstart, SQL and notes CLI; graph is optional on experimental server builds. |
| `live`, `live.admin`, `tables` | The quickstart has an opt-in, read-only Live app listing. Live watch and tables query/mutate/deploy calls are not exercised. |
| Authentication | Optional token/API key via `LOAMS_API_KEY` or `LOAMS_TOKEN`; no sign-in or user provisioning is implied. |
| House | Unavailable as a typed module in SDK 0.1.2. |
