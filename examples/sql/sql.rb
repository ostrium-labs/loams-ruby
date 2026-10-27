# frozen_string_literal: true

# SQL through the SDK module, including parameters and hybrid search functions.
require_relative "../../lib/example_support"

client = LoamsExample.client
LoamsExample.seed(client, "articles")

def run_sql(client, label, sql, params: [])
  puts "-- #{label}"
  Loams::App::Sql.records(client.sql.query(sql, params: params)).each { |row| puts row }
end

run_sql(client, "group by", "SELECT tenant, count(*) AS n FROM articles GROUP BY tenant ORDER BY tenant")
run_sql(client, "parameterized select", "SELECT body, year FROM articles WHERE year >= $1 ORDER BY year", params: [2024])
run_sql(client, "hybrid search", "SELECT _id, _score FROM rrf(" \
  "vector_search('articles', $1, 'embedding', 10), text_search('articles', 'refund', 'body', 10)) LIMIT 3",
  params: [LoamsExample.embed("refund policy")])
