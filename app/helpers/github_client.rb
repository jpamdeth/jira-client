# lib/github_client.rb
require "faraday"
require "faraday_middleware"
require "dotenv/load" # Ensure this line is added to load .env variables

class GithubClient

  # https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28
  BASE_URL = ENV["GITHUB_BASE_URL"]
  PAGE_SIZE = 100

  def self.connection
    @connection ||= Faraday.new(url: BASE_URL) do |conn|
      conn.request :authorization, "Bearer", ENV["GITHUB_API_TOKEN"]
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end

  def self.fetch_page(url, page)
    response = GithubClient.connection.get(url, { page: page, per_page: PAGE_SIZE })

    if response.success?
      response.body
    else
      raise "Failed to fetch page #{page}: #{response.status}"
    end
  end

  def self.fetch_all_pages(url)
    page = 1
    results = []

    loop do
      response = GithubClient.fetch_page(url, page)
      break if response.empty?

      results.concat(response)
      break if response.size < PAGE_SIZE
      page += 1
    end

    results
  end

  def self.fetch_graphql(query, path)
    response = GithubClient.connection.post("/graphql", query: query)
    if response.success?
      result = response.body.dig("data", *path)
      result
    else
      raise "Failed to fetch data: #{response.status}"
    end
  end

  def self.fetch_all_graphql(query, path)
    cursor = ""
    results = []

    loop do
      page = query.gsub("__AFTER__", cursor)
      response = GithubClient.connection.post("/graphql", query: page)

      if response.success?
        result = response.body.dig("data", *path)
        results.concat(result)
        page_info = GithubClient.find_page_info(response.body)
        cursor = page_info[:end_cursor]
        break unless page_info[:has_next_page]
      else
        raise "Failed to fetch data: #{response.status}"
      end
    end

    results
  end

  def self.find_page_info(json)
    if json.is_a?(Hash)
      if json.key?("pageInfo")
        return {
          end_cursor: json["pageInfo"]["endCursor"],
          has_next_page: json["pageInfo"]["hasNextPage"]
        }
      end

      json.each do |key, value|
        result = find_page_info(value)
        return result if result
      end
    elsif json.is_a?(Array)
      json.each do |element|
        result = find_page_info(element)
        return result if result
      end
    end

    raise "pageInfo not found in the response"
  end
end
