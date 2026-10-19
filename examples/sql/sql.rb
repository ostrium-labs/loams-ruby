# frozen_string_literal: true

# SQL over a collection: plain SELECT, then the same hybrid query as the
# quickstart written with rrf(vector_search(...), text_search(...)).
$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "loams_rest"

include LoamsExamples

create_collection("kb", schema(dim: 3))
api(:post, "/collections/kb/documents", { ops: [
  { upsert: { id: 1, source: { body: "refund policy", tenant: "a" }, vectors: { embedding: [1.0, 0.0, 0.0] } } },
  { upsert: { id: 2, source: { body: "shipping times", tenant: "a" }, vectors: { embedding: [0.9, 0.1, 0.0] } } },
  { upsert: { id: 3, source: { body: "refund window", tenant: "b" }, vectors: { embedding: [0.0, 0.0, 1.0] } } }
] })

def run_sql(title, query)
  res = LoamsExamples.api(:post, "/sql", { query: query })
  puts "-- #{title}", query
  cols = res["columns"].map { |c| c["name"] }
  puts cols.join("\t")
  res["rows"].each { |row| puts row.join("\t") }
  puts
end

run_sql("all documents", "SELECT _id, body, tenant FROM kb ORDER BY _id")
run_sql("hybrid search with rrf",
        "SELECT _id, body, _score FROM rrf(" \
        "vector_search('kb', [1.0, 0.0, 0.0], 'embedding', 10), " \
        "text_search('kb', 'refund', 'body', 10)) LIMIT 3")
