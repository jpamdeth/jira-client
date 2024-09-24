class JiraTeamController < ApplicationController
  def index
    begin
      teams = Array(params[:project_key])
      statuses = Array(params[:status])

      unless teams.empty? || statuses.empty?
        created = params[:created]
        updated = params[:updated]
        resolved = params[:resolved]

        jql_conditions = []
        jql_conditions << "project IN (#{teams.map { |team| "\"#{team}\"" }.join(', ')})" unless teams.empty?
        jql_conditions << "status IN (#{statuses.map { |status| "\"#{status}\"" }.join(', ')})" unless statuses.empty?
        jql_conditions << "created >= -#{created}d" unless created == 'Any'
        jql_conditions << "updated >= -#{updated}d" unless updated == 'Any'
        jql_conditions << "resolved >= -#{resolved}d" unless resolved == 'Any'

        unless jql_conditions.empty?
          jql = jql_conditions.join(' AND ') + " AND issuetype IN (Task, Story) order by created DESC"
          start_at = 0
          max_results = 50
          all_issues = []

          loop do
            issues = JIRA_CLIENT.Issue.jql(jql, fields: %w[summary assignee issuetype priority status resolution customfield_10004 customfield_19880 customfield_19971], start_at: start_at, max_results: max_results)
            all_issues.concat(issues)
            break if issues.size < max_results
            start_at += max_results
          end

          @issues = all_issues
        end
      else
        @error = 'Please select a team and a status'
      end
    rescue => e
      @error = e.message
    end
  end
end
