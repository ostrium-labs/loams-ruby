# frozen_string_literal: true

# A tiny notes CLI backed by SDK namespace, collection, document, search and SQL modules.
#
#   ruby examples/notes-cli/notes.rb add "refund policy" --tenant acme
#   ruby examples/notes-cli/notes.rb search refund --tenant acme
#   ruby examples/notes-cli/notes.rb count
require "digest"
require "optparse"
require_relative "../../lib/example_support"

def usage
  warn "usage: notes.rb add TEXT [--tenant T] | search QUERY [--tenant T] | count"
  exit 2
end

tenant = "default"
OptionParser.new { |opts| opts.on("--tenant T") { |value| tenant = value } }.parse!(ARGV)
command = ARGV.shift || usage
client = LoamsExample.client
notes = LoamsExample.ensure_collection(client, "notes")

case command
when "add"
  text = ARGV.join(" ")
  usage if text.empty?
  id = Digest::MD5.hexdigest("#{tenant}:#{text}")[0, 12]
  notes.upsert([{ id: id, source: { body: text, tenant: tenant }, vectors: { embedding: LoamsExample.embed(text) } }])
  puts "saved note #{id} for tenant #{tenant}"
when "search"
  query = ARGV.join(" ")
  usage if query.empty?
  request = Loams::Search.on("notes")
    .text(query, fields: ["body"])
    .vector("embedding", LoamsExample.embed(query))
    .fuse(Loams::Fusion.rrf(60))
    .filter(Loams::Filter.eq("tenant", tenant))
    .limit(5)
  notes.search(request).hits.each do |hit|
    puts "#{Loams::Values.from_document_id(hit.pk)}: #{Loams.to_h(hit.source)["body"]}"
  end
when "count"
  result = client.sql.query("SELECT count(*) AS n FROM notes")
  puts "#{Loams::App::Sql.records(result).first["n"]} notes"
else
  usage
end
