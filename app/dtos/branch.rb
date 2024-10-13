# app/dtos/branch.rb
class Branch
  attr_accessor :name, :repository_name, :owner, :author_email, :commit_date, :employee

  def initialize(name: nil, repository_name: nil, owner: "zendesk", author_email: nil, commit_date: nil, employee: false)
    @name = name
    @repository_name = repository_name
    @owner = owner
    @author_email = author_email
    @commit_date = commit_date
    @employee = employee
  end

  def self.fetch_from_github(owner, repo, branch)
    response = GithubClient.connection.get("/repos/#{owner}/#{repo}/branches/#{branch}")

    if response.success?
      branch_data = response.body
      if branch_data && branch_data["name"]
        branch = new
        branch.name = branch
        branch.repository_name = repo
        branch.owner = owner
        branch.author_email = branch_data["commit"]["commit"]["author"]["email"]
        branch.commit_date = branch_data["commit"]["commit"]["author"]["date"]
        branch
      else
        raise "Invalid branch data"
      end
    else
      raise "Failed to fetch branch: #{response.status}"
    end
  end
end
