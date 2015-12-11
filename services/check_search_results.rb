require 'virtus'

##
# Value object for results from searching a tutorial set for missing badges
class SearchResult
  include Virtus.model

  attribute :code
  attribute :keyword
  attribute :name
  attribute :id
  attribute :url
  attribute :date
  attribute :fees

  def to_json
    to_hash.to_json
  end
end

##
# Service object to check tutorial request from API
class CheckSearchFromAPI
  def initialize(api_url, form)
    @api_url = api_url
    params = form.attributes.delete_if { |_, value| value.blank? }
    @options =  {
      body: params.to_json,
      headers: { 'Content-Type' => 'application/json' }
    }
  end

  def call
    results = HTTParty.post(@api_url, @options)

    if results.code != 200
      return nil
    end
    
    courses_array = []
    results.each do |result|
      search_results = SearchResult.new
      search_results.id = result['id']
      search_results.name = result['name']
      search_results.url = result['url']
      search_results.date = result['date']
      search_results.date = result['fees']
      search_results.code = results.code
      courses_array.push(search_results.clone)
    end
    courses_array
  end
end
