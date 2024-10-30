module JiraTeamHelper
  def self.issue_search(teams, statuses, resolutions, created, updated, resolved, unassigned, unpointed)
    jql_conditions = []
    jql_conditions << "project IN (#{teams.map { |team| "\"#{team}\"" }.join(', ')})" unless teams.empty?
    jql_conditions << "status IN (#{statuses.map { |status| "\"#{status}\"" }.join(', ')})" unless statuses.empty?
    jql_conditions << "resolution IN (#{resolutions.map { |resolution| "\"#{resolution}\"" }.join(', ')})" unless resolutions.empty? if statuses.include?("Resolved")
    jql_conditions << "created >= -#{created}d" unless created == "Any"
    jql_conditions << "updated >= -#{updated}d" unless updated == "Any"
    jql_conditions << "resolved >= -#{resolved}d" unless resolved == "Any" if statuses.include?("Resolved")
    jql_conditions << "assignee IS EMPTY" if unassigned
    jql_conditions << "\"Story Points[Number]\" IS EMPTY" if unpointed
    jql_conditions << "issuetype NOT IN (Epic)"
    jql = jql_conditions.join(" AND ") + " ORDER BY created DESC"

    start_at = 0
    max_results = 50
    all_issues = []

    loop do
      issues = JIRA_CLIENT.Issue.jql(jql, fields: %w[summary assignee issuetype priority status resolution customfield_10004 customfield_19880 customfield_19971], start_at: start_at, max_results: max_results)
      all_issues.concat(issues)
      break if issues.size < max_results || all_issues.size >= 1000
      start_at += max_results
    end

    all_issues
  end

  def self.velocity(project)
    jql_conditions = []
    jql_conditions << "project = \"#{project}\""
    jql_conditions << "resolutiondate >= startOfDay(-168d)"
    jql_conditions << "statusCategory = Done"
    jql_conditions << "resolution = Done"
    jql_conditions << "issuetype NOT IN (Epic)"
    jql = jql_conditions.join(" AND ") + " ORDER BY resolutiondate"

    start_at = 0
    max_results = 50
    all_issues = []

    loop do
      issues = JIRA_CLIENT.Issue.jql(jql, fields: %w[summary assignee issuetype parent priority resolutiondate resolution customfield_10004 customfield_19880 customfield_19971], start_at: start_at, max_results: max_results)
      all_issues.concat(issues)
      break if issues.size < max_results || all_issues.size >= 1000
      start_at += max_results
    end

    all_issues
  end

  # Assuming all_issues is an array of JIRA issues with a 'resolutiondate' field
  # sorted by resolutiondate, this method will bucket the issues into 14-day chunks
  def self.bucket_tickets(all_issues)
    begin
      # Initialize the map to store the buckets
      buckets = Hash.new { |hash, key| hash[key] = [] }

      # Iterate over the sorted issues and bucket them into 14-day chunks
      all_issues.each do |issue|
        resolution_date = Date.parse(issue.fields['resolutiondate'])
        # Find the end date of the 14-day window
        end_date = resolution_date + (13 - (resolution_date.yday % 14))
        # Add the issue to the corresponding bucket
        buckets[end_date] << issue
      end

      buckets
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end

  def self.get_recent_projects
    @recent_projects = JiraClient.fetch_page("/rest/api/3/project/recent", 0)
  end

  def self.get_projects_in_category(category_id)
    @recent_projects = JiraClient.fetch_all_pages("/rest/api/3/project/search?categoryId=#{category_id}")
  end
end
