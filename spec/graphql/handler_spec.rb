# frozen_string_literal: true

require 'spec_helper'

describe PersistedQueries::Handler do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:query_string) { 'query { __typename }' }
  let(:hash) { Digest::SHA256.hexdigest(query_string) }
  let(:params) do
    {
      extensions: {
        persistedQuery: {
          sha256Hash: hash
        }
      }
    }
  end
  let(:fallback_params) { params.merge(query: query_string) }
  let(:query_string_from_cache) { described_class.new(params, cache: memory_store).query_string }

  context 'with a valid hash' do
    it 'saves the query to cache' do
      described_class.new(fallback_params, cache: memory_store).query_string
      expect(query_string_from_cache).to eq(query_string)
    end

    it 'returns nil on first call' do
      expect(query_string_from_cache).to be_nil
    end
  end

  context 'with an invalid hash' do
    let(:hash) { 'INVALID HASH' }

    it 'does not save the query to cache' do
      described_class.new(fallback_params, cache: memory_store).query_string
      expect(query_string_from_cache).to be_nil
    end
  end
end
