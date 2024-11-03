# app/dtos/branch.rb
class Branch
  attr_accessor :name, :branches, :owner, :author_email, :last_committer, :last_commit_date, :employee, :pull_requests, :ahead, :behind, :open_pr

  def initialize(name: nil, repo: nil, owner: "zendesk")
    @name = name
    @repository_name = repo
    @owner = owner
  end

  def self.fetch_from_github(owner, repo, name)
    response = GithubClient.connection.get("/repos/#{owner}/#{repo}/branches/#{name}")

    if response.success?
      branch_data = response.body
      if branch_data && branch_data["name"]
        branch = new
        branch.name = name
        branch.repo = repo
        branch.owner = owner
        branch.author_email = branch_data["commit"]["commit"]["author"]["email"]
        branch.last_commit_date = branch_data["commit"]["commit"]["author"]["date"]
        branch
      else
        raise "Invalid branch data"
      end
    else
      raise "Failed to fetch branch: #{response.status}"
    end
  end

  def self.from_graphql(branch_info)
    branch_node = branch_info.dig("node")
    branch_name = branch_node.dig("name")
    committer_name = branch_node.dig("target", "history", "edges", 0, "node", "committer", "user", "name")
    committer_login = branch_node.dig("target", "history", "edges", 0, "node", "committer", "user", "login")
    committer_email = branch_node.dig("target", "history", "edges", 0, "node", "committer", "email")
    employee = Organization.instance.members.include?(committer_login)
    prs = branch_node.dig("associatedPullRequests", "nodes")
    open_pr = prs.find { |pr| pr["state"] == "OPEN" }

    branch = Branch.new
    branch.name = branch_name
    branch.last_committer = committer_name || committer_email || committer_login
    branch.last_commit_date = branch_node.dig("target", "history", "edges", 0, "node", "committedDate")
    branch.employee = employee
    branch.ahead = branch_node.dig("compare", "behindBy")
    branch.behind = branch_node.dig("compare", "aheadBy")
    branch.open_pr = open_pr

    branch
  end
end
