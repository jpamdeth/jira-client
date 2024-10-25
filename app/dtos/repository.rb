class Repository
  attr_accessor :id, :name, :owner, :html_url, :branches_url, :pulls_url, :teams_url

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
      branch.commit_date = branch_info["commit"]["commit"]["author"]["date"]
      branch.employee = Organization.instance.members.include?(branch_info["commit"]["commit"]["author"]["login"])
      branches << branch
    end

    branches
  end

  def fetch_branches_graphql
    query_template = File.read(Rails.root.join("app", "graphql_queries", "repository_branches.graphql"))
    query = query_template.gsub("__OWNER__", @owner).gsub("__NAME__", @name)

    branch_data = GithubClient.fetch_all_graphql(query, %w[repository refs edges])

    branches = {}
    branch_data.each do |branch_info|
      branch_name = branch_info.dig("node", "name")
      committer_login = branch_info.dig("node", "target", "history", "edges", 0, "node", "committer", "user", "login")
      employee = Organization.instance.members.include?(committer_login)
      branch = Branch.new
      branch.name = branch_name
      branch.repo = @name
      branch.owner = @owner
      branch.author_email = branch_info.dig("node", "target", "history", "edges", 0, "node", "committer", "email")
      branch.commit_date = branch_info.dig("node", "target", "history", "edges", 0, "node", "committedDate")
      branch.employee = employee
      branches[branch_name] = branch
    end

    branches
  end
end
