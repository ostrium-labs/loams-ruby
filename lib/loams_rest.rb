# frozen_string_literal: true

# Shared helpers for the examples.
#
# The Ruby SDK 0.1.0 speaks the Connect services it ships bindings for
# (instance, live, tables). Collections, hybrid query and SQL are on the engine's
# native JSON API, so the examples reach those through this small Net::HTTP
# wrapper, and use the SDK for what it covers. No credentials: a local
# `loams dev` has auth off. Set LOAMS_API_KEY for an instance that needs one.
require "json"
require "net/http"
require "uri"
require "loams"

module LoamsExamples
  extend self
  ENDPOINT = ENV.fetch("LOAMS_ENDPOINT", "http://127.0.0.1:18080")
  NAMESPACE = ENV.fetch("LOAMS_NAMESPACE", "examples-ruby")

  class ApiError < StandardError
    attr_reader :status, :body

    def initialize(status, body)
      @status = status
      @body = body
      super("HTTP #{status}: #{body}")
    end
  end

  def sdk_client
    key = ENV["LOAMS_API_KEY"]
    Loams.client(ENDPOINT, protocol: :connect, codec: :json, token: (key unless key.to_s.empty?))
  end

  # POST/DELETE JSON to the native API under this example's namespace.
  def api(verb, path, body = nil)
    uri = URI("#{ENDPOINT}/v1/namespaces/#{NAMESPACE}#{path}")
    klass = { post: Net::HTTP::Post, delete: Net::HTTP::Delete }.fetch(verb)
    req = klass.new(uri)
    req["content-type"] = "application/json"
    req["authorization"] = "Bearer #{ENV['LOAMS_API_KEY']}" unless ENV["LOAMS_API_KEY"].to_s.empty?
    req.body = JSON.generate(body) if body
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") { |http| http.request(req) }
    raise ApiError.new(res.code.to_i, res.body) unless res.is_a?(Net::HTTPSuccess)

    res.body.to_s.empty? ? {} : JSON.parse(res.body)
  end

  def create_collection(name, schema)
    api(:post, "/collections", { name: name, schema: schema })
  rescue ApiError => e
    raise unless e.status == 409 # already exists: reuse it
  end

  def text_field(name)
    { name: name, source_path: name, kind: { text: { analyzer: "standard", positions: true } }, indexed: true, fast: false }
  end

  def keyword_field(name)
    { name: name, source_path: name, kind: "keyword", indexed: true, fast: true }
  end

  def schema(dim:)
    {
      fields: [text_field("body"), keyword_field("tenant")],
      vectors: [{ name: "embedding", dim: dim, distance: "cosine" }],
      sparse_vectors: [], dynamic: "ignore", max_fields: 1000
    }
  end
end
