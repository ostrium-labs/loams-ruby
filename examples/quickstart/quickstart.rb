# frozen_string_literal: true

# Connect, create a namespace and collection, write documents, then use SDK modules.
require_relative "../../lib/example_support"

client = LoamsExample.client
instance = Loams.to_h(client.instance.get_instance)
puts "engine API versions: #{instance[:api_versions] || instance["api_versions"]}"
articles = LoamsExample.seed(client, "articles")
query = Loams::Search.on("articles")
  .text("refund", fields: ["body"])
  .vector("embedding", LoamsExample.embed("refund policy"))
  .fuse(Loams::Fusion.rrf(60))
  .filter(Loams::Filter.eq("tenant", "a"))
  .limit(3)

puts "text search: #{articles.search(Loams::Search.on("articles").text("refund", fields: ["body"]).limit(3)).hits.length} hits"
puts "vector search: #{client.vector.search("articles", LoamsExample.embed("refund policy"), field: "embedding", limit: 3).hits.length} hits"
client.search.query(query).hits.each do |hit|
  puts "#{Loams::Values.from_document_id(hit.pk)}: #{Loams.to_h(hit.source)["body"]} (#{hit.score.round(3)})"
end

begin
  client.graph.create("examples_graph")
  client.graph.query("examples_graph", "INSERT (:Article {id: $id})", parameters: { id: 1 })
  rows = client.graph.query("examples_graph", "MATCH (a:Article) RETURN a.id", read_only: true)
  puts "experimental graph rows: #{Loams::App::Graph.records(rows).length}"
rescue Loams::FeatureNotInVariantError
  puts "graph is not enabled in this engine build"
end

stream = "example_events"
client.streams.create(stream, partitions: 1)
produced = client.streams.produce(stream, [{ kind: "indexed", id: 1 }], producer_id: "ruby-example", producer_seq: 1)
subscription = client.streams.subscribe(stream, from_offset: produced.base_offset, max_wait_ms: 100)
subscription.each do |event|
  puts "stream event at offset #{event.offset}: #{event.json}"
  subscription.cancel
end

# Explicit opt-in, read-only, and may require Live directory privileges.
if ARGV.include?("--live-admin")
  raise "this server does not serve live.admin" unless instance.fetch(:api_versions, instance["api_versions"]).to_a.include?("loams.live.v1")

  apps = Loams.to_h(client.module("live.admin").list_apps)
  puts "Live apps visible to this credential: #{(apps[:apps] || apps["apps"] || []).length}"
end
