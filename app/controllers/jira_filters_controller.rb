class JiraFiltersController < ApplicationController
  def index
    begin
      result = []
      url = "/rest/api/3/filter/my"
      response = JIRA_CLIENT.get(url)
      json = JSON.parse(response.body)
      json.map do |filter|
        result.push(JIRA_CLIENT.Filter.build(filter))
      end
      @filters = result
    rescue => e
      @error = e.message
    end
  end

  def show
    begin
      @filter = JIRA_CLIENT.Filter.find(params[:id])
      jql = "filter=#{@filter.id}"
      @issues = JIRA_CLIENT.Issue.jql(jql, fields: %w[summary assignee issuetype priority status resolution customfield_10004 customfield_19880 customfield_19971])
    rescue => e
      @error = e.message
    end
  end
end
