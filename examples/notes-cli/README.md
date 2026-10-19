# notes-cli

A plain Ruby script: `add`, `search` (hybrid, filtered by `--tenant`) and `count`. Text is hashed into an 8-dimension vector so it needs no embedding model; replace `embed` with a real one for real use.

```sh
bundle exec ruby examples/notes-cli/notes.rb add "refund policy" --tenant acme
bundle exec ruby examples/notes-cli/notes.rb search refund --tenant acme
bundle exec ruby examples/notes-cli/notes.rb count
```
