# frozen_string_literal: true

# Connect, create a collection, upsert documents, run a hybrid search
# (vector + BM25 + filter) and print the results.
$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "loams_rest"

include LoamsExamples

info = sdk_client.instance.get_instance
puts "connected to #{info.name} #{info.server_version} (#{info.edition}) at #{ENDPOINT}"
puts "namespace: #{NAMESPACE}"

create_collection("kb", schema(dim: 3))

api(:post, "/collections/kb/documents", { ops: [
  { upsert: { id: 1, source: { body: "refund policy", tenant: "a" }, vectors: { embedding: [1.0, 0.0, 0.0] } } },
  { upsert: { id: 2, source: { body: "shipping times", tenant: "a" }, vectors: { embedding: [0.9, 0.1, 0.0] } } },
  { upsert: { id: 3, source: { body: "refund window", tenant: "b" }, vectors: { embedding: [0.0, 0.0, 1.0] } } }
] })

result = api(:post, "/query", {
  from: "collections.kb",
  retrieve: [
    { vector: { field: "embedding", query: [1.0, 0.0, 0.0], k: 10 } },
    { text: { field: "body", query: "refund", k: 10 } }
  ],
  filter: { term: { tenant: "a" } },
  fuse: { method: "rrf", k: 60 },
  limit: 3
})

puts JSON.pretty_generate(result)
