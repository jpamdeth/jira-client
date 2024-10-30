# README

* Ruby version

3.2.4

* Configuration

Generate a JIRA API token that has read access.  Create a GitHub personal access token.

Create '.env' in the top level directory with these keys:<br>
JIRA_SITE=<br>
JIRA_USERNAME=<br>
JIRA_API_TOKEN=<br>
GITHUB_BASE_URL=<br>
GITHUB_API_TOKEN=<br>


* Deployment instructions

Use 'rails server' to start the service.  By default it runs on http://127.0.0.1:3000
