# frozen_string_literal: true

require "loams"
require "digest"

module LoamsExample
  NAMESPACE = ENV.fetch("LOAMS_NAMESPACE", "examples-ruby")
  DIM = 8

  def self.client
    ENV["LOAMS_NAMESPACE"] ||= NAMESPACE
    Loams.from_env(session_consistency: true)
  end

  def self.ensure_collection(client, name)
    begin
      client.namespaces.create(client.namespace)
    rescue Loams::AlreadyExistsError
      # Reuse this disposable example namespace.
    end
    schema = Loams::Schema.new.text("body").keyword("tenant").i64("year").vector("embedding", DIM)
    begin
      client.collections.create(name, schema: schema)
    rescue Loams::AlreadyExistsError
      # The stable example schema already exists.
    end
    client.collection(name)
  end

  def self.embed(text)
    vector = Array.new(DIM, 0.0)
    text.downcase.scan(/[a-z0-9]+/).each { |word| vector[Digest::MD5.digest(word).unpack1("C") % DIM] += 1.0 }
    norm = Math.sqrt(vector.sum { |value| value * value })
    norm.zero? ? [1.0] + Array.new(DIM - 1, 0.0) : vector.map { |value| value / norm }
  end

  def self.seed(client, name)
    collection = ensure_collection(client, name)
    collection.upsert([
      { id: 1, source: { body: "refund policy for damaged items", tenant: "a", year: 2024 }, vectors: { embedding: embed("refund policy damaged items") } },
      { id: 2, source: { body: "shipping times and carriers", tenant: "a", year: 2025 }, vectors: { embedding: embed("shipping times carriers") } },
      { id: 3, source: { body: "refund window is thirty days", tenant: "b", year: 2023 }, vectors: { embedding: embed("refund window thirty days") } },
      { id: 4, source: { body: "how to reset your password", tenant: "a", year: 2022 }, vectors: { embedding: embed("reset password") } },
    ])
    collection
  end
end
