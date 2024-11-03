class Repository
  attr_accessor :name, :owner, :html_url, :default_branch

  def initialize(name:, owner: "zendesk")
    @name = name
    @owner = owner
  end

  def fetch_from_github
    response = GithubClient.connection.get("/repos/#{@owner}/#{@name}")

    if response.success?
      repo_data = response.body
      if repo_data && repo_data["id"]
        @html_url = repo_data["html_url"]
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
    query_template = File.read(Rails.root.join("app", "graphql_queries", "repository_branches.graphql"))
    query = query_template.gsub("__OWNER__", @owner).gsub("__NAME__", @name).gsub("__DEFAULT__", @default_branch)

    branch_data = GithubClient.fetch_all_graphql(query, %w[repository refs edges])

    branches = branch_data.map do |branch_info|
      Branch.from_graphql(branch_info)
    end

    branches.sort_by! { |branch| DateTime.parse(branch.last_commit_date) }
  end

  def fetch_pull_requests
    query_template = File.read(Rails.root.join("app", "graphql_queries", "pull_requests.graphql"))
    query = query_template.gsub("__OWNER__", @owner).gsub("__NAME__", @name)

    pr_data = GithubClient.fetch_all_graphql(query, %w[repository pullRequests nodes])

    prs = pr_data.map do |pr_info|
      PullRequest.from_graphql(pr_info, @name, @owner)
    end
  end
end
