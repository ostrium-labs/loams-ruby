# notes-cli

A plain Ruby script using SDK namespace, collection, document, search and SQL modules for `add`, `search` and `count`. Text is hashed into an 8-dimensional vector, so it needs no embedding model; replace it with a real one for real use.

```sh
bundle exec ruby examples/notes-cli/notes.rb add "refund policy" --tenant acme
bundle exec ruby examples/notes-cli/notes.rb search refund --tenant acme
bundle exec ruby examples/notes-cli/notes.rb count
```
