# lib/github_client.rb
require "faraday"
require "faraday_middleware"
require "dotenv/load" # Ensure this line is added to load .env variables

class JiraClient

  # https://developer.atlassian.com/cloud/jira/platform/rest/v2/intro/#about
  BASE_URL = ENV["JIRA_SITE"]
  MAX_RESULTS = 50

  def self.connection
    @connection ||= Faraday.new(url: BASE_URL) do |conn|
      conn.request :basic_auth, ENV["JIRA_USERNAME"], ENV["JIRA_API_TOKEN"]
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end

  def self.fetch_page(url, start_at)
    response = JiraClient.connection.get(url, { startAt: start_at, maxResults: MAX_RESULTS })

    if response.success?
      response.body
    else
      raise "Failed to fetch from #{start_at}: #{response.status}"
    end
  end

  def self.fetch_all_pages(url)
    start_at = 0
    results = []

    loop do
      response = JiraClient.fetch_page(url, start_at)
      break if response.empty?

      results.concat(response["values"])
      break if response["isLast"]
      start_at += MAX_RESULTS
    end

    results
  end
end
