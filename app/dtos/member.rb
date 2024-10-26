class Member
  attr_accessor :name, :email, :login, :id, :url

  def initialize(attributes = {})
    @login = attributes["login"]
    @id = attributes["id"]
  end

  def self.fetch(login)
    query_template = File.read(Rails.root.join("app", "graphql_queries", "user.graphql"))
    query = query_template.gsub("__LOGIN__", login)
    response = GithubClient.fetch_graphql(query, %w[user])
    member = Member.new
    member.login = response["login"]
    member.email = response["email"]
    member.name = response["name"]
    member.url = response["url"]
    member
  end

  def self.fetch_contributions(login)
    query_template = File.read(Rails.root.join("app", "graphql_queries", "user_contributions.graphql"))
    query = query_template.gsub("__LOGIN__", login)

    contributions = GithubClient.fetch_graphql(query, %w[user contributionsCollection])
    contributions
  end
end
