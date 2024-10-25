class Member
  attr_accessor :name, :email, :login, :id, :url

  def initialize(attributes = {})
    @login = attributes["login"]
    @id = attributes["id"]
  end

  def self.fetch_team(team, org = "zendesk")
    members = []
    response = GithubClient.fetch_all_pages("/orgs/#{org}/teams/#{team}/members")
    response.map do |member_info|
      query_template = File.read(Rails.root.join("app", "graphql_queries", "user.graphql"))
      query = query_template.gsub("__LOGIN__", member_info["login"])
      response = GithubClient.fetch_graphql(query, %w[user])
      member = Member.new
      member.login = member_info["login"]
      member.id = response["id"]
      member.email = response["email"]
      member.name = response["name"]
      member.url = response["url"]
      members << member
    end
    members
  end

  def self.fetch_contributions(login)
    query_template = File.read(Rails.root.join("app", "graphql_queries", "user_contributions.graphql"))
    query = query_template.gsub("__LOGIN__", login)

    contributions = GithubClient.fetch_graphql(query, %w[user contributionsCollection])
  end
end
