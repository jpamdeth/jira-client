# app/dtos/branch.rb
class PullRequest
  attr_accessor :title, :repo, :owner, :branch, :created_at, :updated_at, :number, :author_login, :employee, :additions, :deletions, :changed_files, :commits, :url

  def initialize(number: nil, repo: nil, owner: "zendesk")
    @number = number
    @repo = repo
    @owner = owner
  end

  def self.fetch_from_github(owner, repo, number)
    response = GithubClient.connection.get("/repos/#{owner}/#{repo}/pulls/#{number}")

    if response.success?
      pr_data = response.body
      if pr_data && pr_data["number"]
        pull = new
        pull.title = pr_data["title"]
        pull.repo = repo
        pull.owner = owner
        pull.number = pr_data["number"]
        pull.branch = pr_data["head"]["ref"]
        pull.author_login = pr_data["user"]["login"]
        pull.created_at = pr_data["created_at"]
        pull.updated_at = pr_data["updated_at"]
        pull.additions = pr_data["additions"]
        pull.deletions = pr_data["deletions"]
        pull.changed_files = pr_data["changed_files"]
        pull.commits = pr_data["commits"]
        pull.url = pr_data["html_url"]
        pull
      else
        raise "Invalid pull request data"
      end
    else
      raise "Failed to fetch pull request: #{response.status}"
    end
  end

  def self.from_graphql(pr_info, repo, owner)
    pr = PullRequest.new
    pr.title = pr_info.dig("title")
    pr.repo = repo
    pr.owner = owner
    pr.author_login = pr_info.dig("author", "login")
    pr.number = pr_info.dig("number")
    pr.created_at = pr_info.dig("createdAt")
    pr.updated_at = pr_info.dig("updatedAt")
    pr.additions = pr_info.dig("additions")
    pr.deletions = pr_info.dig("deletions")
    pr.changed_files = pr_info.dig("changedFiles")
    pr.commits = pr_info.dig("commits", "totalCount")
    pr.employee = Organization.instance.members.include?(pr.author_login)
    pr.url = pr_info.dig("url")
    pr
  end
end
