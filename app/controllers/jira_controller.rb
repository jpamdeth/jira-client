class JiraController < ApplicationController
  include ApplicationHelper
  def index
    begin
      @recent_projects = JiraHelper.get_recent_projects

      teams = Array(params[:project_key])
      statuses = Array(params[:status])

      if teams.empty? || statuses.empty?
        @error = "Please select a team and a status"
      else
        resolutions = Array(params[:resolution])
        created = params[:created]
        updated = params[:updated]
        resolved = params[:resolved]
        unassigned = params[:unassigned] == "1"
        unpointed = params[:unpointed] == "1"

        @issues = JiraHelper.issue_search(teams, statuses, resolutions, created, updated, resolved, unassigned, unpointed)
        if @issues.size >= 1000
          @error = "The maximum of 1000 issues was returned. Results may have been capped."
        end
      end
    rescue => e
      @error = e.message
    end
  end

  def velocity
    begin
      @team = params[:project_key]

      if @team.nil?
        @error = "Please select a team"
      else
        all_issues = JiraHelper.velocity(@team)
        @buckets = JiraHelper.bucket_tickets(all_issues)
      end
    rescue => e
      @error = e.message
    end
  end
end
