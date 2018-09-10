# frozen_string_literal: true

module PersistedQueries
  class Handler
    def initialize(params, cache: Rails.cache)
      @params = params
      @cache = cache
    end

    def persisted_query?
      params[:query].nil? && params.dig(:extensions, :persistedQuery).present?
    end

    def query_string
      @query_string ||= fetch_query_string
    end

    private

    attr_reader :params
    attr_reader :cache

    def fetch_query_string
      return if hash.nil?

      query_string = params[:query]
      if query_string.present? && hash_valid?(query_string)
        write_cache(query_string)
      else
        read_cache
      end
    end

    def hash
      @hash ||= params.dig(:extensions, :persistedQuery, :sha256Hash)
    end

    def hash_valid?(query_string)
      hash == Digest::SHA256.hexdigest(query_string)
    end

    def cache_key
      [:persisted_queries, hash]
    end

    def write_cache(query_string)
      cache.write(cache_key, query_string)
      query_string
    end

    def read_cache
      cache.read(cache_key)
    end
  end
end
