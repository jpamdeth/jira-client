class Member
  attr_accessor :name, :email, :login, :id, :node_id

  def initialize(attributes = {})
    @name = attributes["name"]
    @email = attributes["email"]
    @login = attributes["login"]
    @id = attributes["id"]
    @node_id = attributes["node_id"]
  end

  def self.fetch_from_github(org: "zendesk", team:)
    page = 1
    members = []

    loop do
      response = GithubClient.get_page("/orgs/#{org}/teams/#{team}/members", page)
      break if response.body.empty?

      response.body.each do |member_data|
        members << new(member_data)
      end

      break if response.body.size < 100 # Break if fewer than 100 results are returned
      page += 1
    end

    members
  end
end
