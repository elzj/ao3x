class Search
  include Searching::Utilities
  attr_reader :options

  def self.client
    Elasticsearch::Client.new host: ArchiveConfig.elasticsearch[:url]
  end

  class << self
    delegate :klass, :index_name, :document_type, to: :main_indexer
  end
  delegate :klass, :index_name, :document_type, to: :class

  def self.get(id)
    client.get(
      index: index_name,
      type: document_type,
      id: id
    )
  end

  attr_reader :client

  # Options: page, per_page
  def initialize(options={})
    @options = HashWithIndifferentAccess.new(options)
    @client = self.class.client
  end

  def search
    client.search(
      index: index_name,
      type: document_type,
      body: generated_query
    )
  rescue Faraday::ConnectionFailed
    { error: 'Sorry, our search engine is unavailable right now!' }
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest
    { error: 'This search failed because of a syntax error. Please try again.' }
  end

  def suggest(term, options = {})
    body = {
      "_source" => "suggest",
      suggest: {
        autocomplete_me: {
          prefix: term,
          completion: {
            field: "suggest",
            contexts: options[:contexts] || {},
            size: options[:size] || 10
          }
        }
      }
    }
    results = client.search(
      index: index_name,
      type: document_type,
      body: body
    )
    results.dig('suggest', 'autocomplete_me').
            first['options'].
            map{ |r| r.dig('_source', 'suggest', 'input').first } rescue []
  end

  def search_results
    response = search
    # QueryResult.new(klass, response, { page: page, per_page: per_page })
  end

  # Perform a count query based on the given options
  def count
    client.count(
      index: index_name,
      body: { query: generated_query[:query] }
    )['count']
  end

  # Sort by relevance by default, override in subclasses as necessary
  def sort
    { "_score" => { order: "desc" }}
  end

  # Search query with filters
  def generated_query
    q = {
      query: filtered_query,
      size: per_page,
      from: pagination_offset,
      sort: sort
    }
    if aggregations.present?
      q.merge!(aggregations)
    end
    q
  end

  # Combine the filters and queries
  def filtered_query
    make_bool(
      must: queries, # required, score calculated
      filter: filters, # required, score ignored
      must_not: exclusion_filters # disallowed, score ignored
    )
  end

  # Define specifics in subclasses

  def filters
    @filters
  end

  def term_filter(field, value, options={})
    { term: options.merge(field => value) }
  end

  def terms_filter(field, value, options={})
    { terms: options.merge(field => value) }
  end

  # A filter used to match all words in a particular field, most frequently
  # used for matching non-existent tags. The match query doesn't allow
  # negation/or/and/wildcards, so it should only be used on fields where the
  # users are expected to enter, e.g. canonical tags.
  def match_filter(field, value, options = {})
    { match: { field => { query: value, operator: "and" }.merge(options) } }
  end

  # Set the score equal to the value of a field. The optional value "missing"
  # determines what score value should be used if the specified field is
  # missing from a document.
  def field_value_score(field, missing: 0)
    {
      function_score: {
        field_value_factor: {
          field: field,
          missing: missing
        }
      }
    }
  end

  def exclusion_filters
    @exclusion_filters
  end

  def queries
  end

  def aggregations
  end

  def per_page
    options[:per_page] ? options[:per_page].to_i : 25
  end

  # Example: if the limit is 3 results, and we're displaying 2 per page,
  # disallow pages beyond page 2.
  def page
    options[:page] ? options[:page].to_i : 1
  end

  def pagination_offset
    (page * per_page) - per_page
  end
end
