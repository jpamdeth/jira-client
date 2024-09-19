# README

* Ruby version

3.2.4

* Configuration

Generate a JIRA API token that has read access.

Create '.env' in the top level directory with these keys:
JIRA_SITE=
JIRA_USERNAME=
JIRA_API_TOKEN=

* Deployment instructions

Use 'rails server' to start the service.  By default it runs on http://127.0.0.1:3000

URLs:
http://127.0.0.1:3000/jira_issues  :  Lists your assigned tickets and provides links to more details

http://127.0.0.1:3000/jira_filters  :  List your created filters anad links to the matching tickets