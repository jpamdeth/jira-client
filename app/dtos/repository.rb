class Repository
  attr_accessor :id, :name, :owner, :html_url, :branches_url, :pulls_url, :teams_url, :default_branch

  def initialize(name:, owner: "zendesk")
    @name = name
    @owner = owner
  end

  def fetch_from_github
    response = GithubClient.connection.get("/repos/#{@owner}/#{@name}")

    if response.success?
      repo_data = response.body
      if repo_data && repo_data["id"]
        @id = repo_data["id"]
        @html_url = repo_data["html_url"]
        @branches_url = repo_data["branches_url"].gsub("{/branch}", "")
        @pulls_url = repo_data["pulls_url"].gsub("{/number}", "")
        @teams_url = repo_data["teams_url"]
        @default_branch = repo_data["default_branch"]
      else
        raise "Invalid repository data"
      end
    else
      raise "Failed to fetch repository: #{response.status}"
    end

    self
  end

  def fetch_branches
    url = ("/repos/#{@owner}/#{@name}/branches")
    branches = []
    results = GithubClient.fetch_all_pages(url)
    results.map do |branch_info|
      branch = Branch.new(
        name: branch_info["name"],
        repo: @name,
        owner: @owner
      )
      branch.author_email = branch_info["commit"]["commit"]["author"]["email"]
      branch.last_commit_date = branch_info["commit"]["commit"]["author"]["date"]
      branch.employee = Organization.instance.members.include?(branch_info["commit"]["commit"]["author"]["login"])
      branches << branch
    end

    branches
  end

  def fetch_branches_graphql
    query_template = File.read(Rails.root.join("app", "graphql_queries", "repository_branches.graphql"))
    query = query_template.gsub("__OWNER__", @owner).gsub("__NAME__", @name).gsub("__DEFAULT__", @default_branch)

    branch_data = GithubClient.fetch_all_graphql(query, %w[repository refs edges])

    branches = []
    branch_data.each do |branch_info|
      branch_name = branch_info.dig("node", "name")
      committer_name = branch_info.dig("node", "target", "history", "edges", 0, "node", "committer", "user", "name")
      committer_login = branch_info.dig("node", "target", "history", "edges", 0, "node", "committer", "user", "login")
      committer_email = branch_info.dig("node", "target", "history", "edges", 0, "node", "committer", "email")
      employee = Organization.instance.members.include?(committer_login)
      prs = branch_info.dig("node", "associatedPullRequests", "nodes")
      open_pr = prs.find { |pr| pr["state"] == "OPEN" }
      branch = Branch.new
      branch.name = branch_name
      branch.last_committer = committer_name || committer_email || committer_login
      branch.last_commit_date = branch_info.dig("node", "target", "history", "edges", 0, "node", "committedDate")
      branch.employee = employee
      branch.ahead = branch_info.dig("node", "compare", "behindBy")
      branch.behind = branch_info.dig("node", "compare", "aheadBy")
      branch.open_pr = open_pr
      branches << branch
    end

    branches.sort_by! { |branch| DateTime.parse(branch.last_commit_date) }
  end
end
