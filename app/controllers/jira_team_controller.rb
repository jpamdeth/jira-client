class JiraTeamController < ApplicationController
  include ApplicationHelper
  def index
    begin
      teams = Array(params[:project_key])
      statuses = Array(params[:status])
      resolutions = Array(params[:resolution])

      if teams.empty? || statuses.empty?
        @error = "Please select a team and a status"
      else
        created = params[:created]
        updated = params[:updated]
        resolved = params[:resolved]
        unassigned = params[:unassigned] == "1"
        unpointed = params[:unpointed] == "1"

        jql_conditions = []
        jql_conditions << "project IN (#{teams.map { |team| "\"#{team}\"" }.join(', ')})" unless teams.empty?
        jql_conditions << "status IN (#{statuses.map { |status| "\"#{status}\"" }.join(', ')})" unless statuses.empty?
        jql_conditions << "resolution IN (#{resolutions.map { |resolution| "\"#{resolution}\"" }.join(', ')})" unless resolutions.empty? if statuses.include?("Resolved")
        jql_conditions << "created >= -#{created}d" unless created == "Any"
        jql_conditions << "updated >= -#{updated}d" unless updated == "Any"
        jql_conditions << "resolved >= -#{resolved}d" unless resolved == "Any" if statuses.include?("Resolved")
        jql_conditions << "assignee IS EMPTY" if unassigned
        jql_conditions << "\"Story Points[Number]\" IS EMPTY" if unpointed

        unless jql_conditions.empty?
          jql = jql_conditions.join(" AND ") + " AND issuetype NOT IN (Epic) order by created DESC"
          start_at = 0
          max_results = 50
          all_issues = []

          loop do
            issues = JIRA_CLIENT.Issue.jql(jql, fields: %w[summary assignee issuetype priority status resolution customfield_10004 customfield_19880 customfield_19971], start_at: start_at, max_results: max_results)
            all_issues.concat(issues)
            break if issues.size < max_results || all_issues.size >= 500
            start_at += max_results
          end

          @issues = all_issues
          if all_issues.size >= 500
            @error = "A maximum of 500 issues can be returned. Please refine your search."
          end
        end
      end
    rescue => e
      @error = e.message
    end
  end

  def stats
    begin
      team = params[:project_key]
      updated = params[:updated]

      if team.nil? || updated.nil?
        @error = "Please select a team and a time period"
      else
        jql_conditions = []
        jql_conditions << "project = \"#{team}\""
        jql_conditions << "(updated >= -#{updated}d OR created >= -#{updated}d)"
        jql = jql_conditions.join(" AND ") + " AND issuetype NOT IN (Epic) order by created DESC"
        start_at = 0
        max_results = 100
        all_issues = []

        loop do
          issues = JIRA_CLIENT.Issue.jql(jql, fields: %w[summary assignee issuetype priority status resolution customfield_10004 customfield_19880 customfield_19971], start_at: start_at, max_results: max_results)
          all_issues.concat(issues)
          break if issues.size < max_results || all_issues.size >= 1000
          start_at += max_results
        end

        @issues = all_issues
        if all_issues.size >= 1000
          @error = "A maximum of 1000 issues can be returned. Please refine your search."
        end
      end
    rescue => e
      @error = e.message
    end
  end
  def show
    @issue = get_ticket(params[:id])
  rescue => e
    redirect_to jira_team_index_path, alert: e.message
  end

  def velocity
    begin
      team = params[:project_key]

      if team.nil?
        @error = "Please select a team"
      else
        jql_conditions = []
        jql_conditions << "project = \"#{team}\""
        jql_conditions << "resolutiondate >= startOfDay(-168d)"
        jql_conditions << "statusCategory = Done"
        jql_conditions << "resolution = Done"
        jql_conditions << "issuetype NOT IN (Epic)"
        jql = jql_conditions.join(" AND ") + " ORDER BY resolutiondate"
        start_at = 0
        max_results = 100
        all_issues = []

        loop do
          issues = JIRA_CLIENT.Issue.jql(jql, fields: %w[summary assignee issuetype priority resolutiondate resolution customfield_10004 customfield_19880 customfield_19971], start_at: start_at, max_results: max_results)
          all_issues.concat(issues)
          break if issues.size < max_results || all_issues.size >= 1000
          start_at += max_results
        end

        if all_issues.size >= 1000
          @error = "A maximum of 1000 issues can be returned. Please refine your search."
        end

        @buckets = JiraTeamHelper.bucket_tickets_by_14_day_chunks(all_issues)
      end
    rescue => e
      @error = e.message
    end
  end
end
