class JiraIssuesController < ApplicationController
  include ApplicationHelper
  def index
    begin
      @issues = JIRA_CLIENT.Issue.jql("assignee=currentUser()")
    rescue => e
      @error = e.message
    end
  end

  def show
    @issue = get_ticket(params[:id])
  rescue => e
    redirect_to jira_issues_path, alert: e.message
  end
end
