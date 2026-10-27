# quickstart

Uses SDK modules to create/reuse a namespace and collection, upsert articles, run text,
vector and hybrid search, demonstrate experimental graph, query SQL, and produce/subscribe
to stream events. Instance discovery remains part of client setup.

```sh
bundle exec ruby examples/quickstart/quickstart.rb
bundle exec ruby examples/quickstart/quickstart.rb --live-admin  # optional, read-only
```

The optional app-directory listing requires a server that serves `live.admin` and a
credential authorized to list apps.
