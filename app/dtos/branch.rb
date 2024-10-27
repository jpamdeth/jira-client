# app/dtos/branch.rb
class Branch
  attr_accessor :name, :repo, :owner, :author_email, :last_committer, :last_commit_date, :employee, :pull_requests, :ahead, :behind, :open_pr

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
end
