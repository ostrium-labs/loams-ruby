# frozen_string_literal: true

# A tiny notes search CLI: a plain Ruby script, no framework.
#
#   ruby examples/notes-cli/notes.rb add "refund policy for annual plans" --tenant acme
#   ruby examples/notes-cli/notes.rb search refund --tenant acme
#   ruby examples/notes-cli/notes.rb count
#
# There is no embedding model here: text is hashed into an 8-dimension
# bag-of-words vector so the example runs with nothing else installed. Swap
# `embed` for a real model and raise DIM to match.
$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "digest"
require "optparse"
require "loams_rest"

include LoamsExamples

DIM = 8
COLLECTION = "notes"

def embed(text)
  vec = Array.new(DIM, 0.0)
  text.downcase.scan(/\w+/).each { |w| vec[Digest::MD5.digest(w).unpack1("C") % DIM] += 1.0 }
  vec[0] = 1.0 if vec.all?(&:zero?) # cosine needs a non-zero vector
  vec
end

def usage
  warn "usage: notes.rb add TEXT [--tenant T] | search QUERY [--tenant T] | count"
  exit 2
end

tenant = "default"
OptionParser.new { |o| o.on("--tenant T") { |t| tenant = t } }.parse!(ARGV)
cmd = ARGV.shift or usage

create_collection(COLLECTION, schema(dim: DIM))

case cmd
when "add"
  text = ARGV.join(" ")
  usage if text.empty?
  id = Digest::MD5.hexdigest("#{tenant}:#{text}")[0, 12].to_i(16)
  api(:post, "/collections/#{COLLECTION}/documents", { ops: [
    { upsert: { id: id, source: { body: text, tenant: tenant }, vectors: { embedding: embed(text) } } }
  ] })
  puts "saved note #{id} for tenant #{tenant}"
when "search"
  q = ARGV.join(" ")
  usage if q.empty?
  res = api(:post, "/query", {
    from: "collections.#{COLLECTION}",
    retrieve: [
      { vector: { field: "embedding", query: embed(q), k: 10 } },
      { text: { field: "body", query: q, k: 10 } }
    ],
    filter: { term: { tenant: tenant } },
    fuse: { method: "rrf", k: 60 },
    limit: 5
  })
  puts JSON.pretty_generate(res)
when "count"
  res = api(:post, "/sql", { query: "SELECT count(*) AS n FROM #{COLLECTION}" })
  puts "#{res['rows'].dig(0, 0)} notes"
else
  usage
end
