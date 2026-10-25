# Loams Ruby examples

These examples target **Loams SDK 0.1.2**. Installation and CI require the matching
0.1.2 packages and release tags to be published.

[Loams](https://loams.dev) is an open-source engine for hybrid search (vector, BM25 and filters) and SQL over collections of documents. This repository has runnable Ruby examples for the Loams Ruby SDK (gem `loams`, source in [ostrium-labs/loams `sdks/ruby`](https://github.com/ostrium-labs/loams/tree/main/sdks/ruby)).

## Install

```sh
bundle install
```

The `Gemfile` pins the RubyGems package to `loams` 0.1.2. Needs Ruby 3.1 or newer. After publication, run `bundle install` and commit the generated `Gemfile.lock`.

## What the SDK covers

The SDK provides namespaces, collections, documents, search, vector, graph, SQL and streams. These examples retain [`lib/loams_rest.rb`](lib/loams_rest.rb) for native HTTP JSON route demonstrations, using the SDK for instance discovery. See the [SDK notes example](https://github.com/ostrium-labs/loams/blob/v0.1.2/sdks/ruby/examples/notes/notes.rb) for SDK builders and collection handles.

## Run against a local engine

Start an engine (see [docs/release/preview.md](https://github.com/ostrium-labs/loams/blob/main/docs/release/preview.md) for the compose stack):

```sh
cargo run --release -p loams -- dev
```

Point the examples at it. `LOAMS_ENDPOINT` defaults to `http://127.0.0.1:8080`, `LOAMS_NAMESPACE` to `examples-ruby`, and `LOAMS_API_KEY` is only needed if auth is on:

```sh
export LOAMS_ENDPOINT=http://127.0.0.1:8080   # the default `loams dev` port
bundle exec ruby examples/quickstart/quickstart.rb
bundle exec ruby examples/sql/sql.rb
bundle exec ruby examples/notes-cli/notes.rb search refund --tenant acme
```

| Example | What it shows |
|---|---|
| [quickstart](examples/quickstart) | connect, create a collection, upsert documents, hybrid search |
| [sql](examples/sql) | SQL over a collection with `rrf`, `vector_search`, `text_search` |
| [notes-cli](examples/notes-cli) | a plain-Ruby notes search script |

Docs: <https://loams.dev/docs>. Release notes and the status of each surface: [docs/release/preview.md](https://github.com/ostrium-labs/loams/blob/main/docs/release/preview.md). Loams 0.1.2 is a preview and its APIs can change.

Licensed under Apache-2.0 (see `LICENSE`).
