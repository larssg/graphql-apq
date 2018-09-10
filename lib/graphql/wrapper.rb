# frozen_string_literal: true

module PersistedQueries
  class Wrapper
    def initialize(schema:, params:, context:)
      @schema = schema
      @params = params
      @context = context
      @handler = Handler.new(params)
    end

    def call
      if handler.query_string.nil? && handler.persisted_query?
        {
          errors: [
            message: 'PersistedQueryNotFound'
          ]
        }
      else
        schema.execute(
          handler.query_string,
          variables: query_variables,
          context:   context
        )
      end
    end

    private

    attr_reader :schema
    attr_reader :params
    attr_reader :context
    attr_reader :handler

    def query_variables
      @query_variables = ensure_hash(params[:variables])
    end

    def ensure_hash(query_variables)
      if query_variables.blank? || query_variables == 'null'
        {}
      elsif query_variables.is_a?(String)
        JSON.parse(query_variables)
      else
        query_variables
      end
    end
  end
end
