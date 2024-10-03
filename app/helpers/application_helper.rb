module ApplicationHelper
  def get_ticket(ticket_id)
    response = JIRA_CLIENT.Issue.jql("id=#{ticket_id}", fields: %w[summary description assignee issuetype priority status resolution customfield_10004 customfield_19880 customfield_19971 customfield_16100])
    issue = response.first
    pull_request_string = issue.fields["customfield_16100"]
    if pull_request_string == "{}"
      issue.fields["customfield_16100"] = "No pull request"
    else
      json_value = pull_request_string.match(/"pullrequest":(\{.*})}},"isStale"/)[1]
      parsed_json = JSON.parse(json_value)
      issue.fields["customfield_16100"] = parsed_json["overall"]["state"]
    end
    issue
  end

  def format_links(text)
    return "" if text.nil?
    text.gsub(/\[(.*?)\|(.*?)\]/, '<a href="\2" target="_blank">\1</a>').html_safe
  end
end
