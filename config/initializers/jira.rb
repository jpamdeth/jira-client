require "jira-ruby"

options = {
  username:     ENV["JIRA_USERNAME"],
  password:     ENV["JIRA_API_TOKEN"],
  site:         ENV["JIRA_SITE"],
  context_path: "",
  auth_type:    :basic,
  use_ssl:      true
}

JIRA_CLIENT = JIRA::Client.new(options)
