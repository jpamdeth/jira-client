class JiraIssuesController < ApplicationController
  def index
    begin
      @issues = JIRA_CLIENT.Issue.jql("assignee=currentUser()")
    rescue => e
      @error = e.message
    end
  end

  def show
    @issue = JIRA_CLIENT.Issue.find(params[:id])
  rescue => e
    redirect_to jira_issues_path, alert: e.message
  end

  def new
    # For rendering the new issue form
  end

  def create
    issue_fields = {
      "fields" => {
        "project" => { "key" => params[:project_key] },
        "summary" => params[:summary],
        "description" => params[:description],
        "issuetype" => { "name" => params[:issue_type] }
      }
    }

    issue = JIRA_CLIENT.Issue.build
    if issue.save(issue_fields)
      redirect_to jira_issue_path(issue.key), notice: "Issue was successfully created."
    else
      render :new
    end
  rescue => e
    redirect_to new_jira_issue_path, alert: e.message
  end
end
