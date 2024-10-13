require "set"

class Organization
  @instance = nil

  private_class_method :new

  attr_accessor :name, :members, :members_file_path

  def initialize(name: "zendesk")
    @name = name
    @members = Set.new
    home_dir = Dir.home
    @members_file_path = File.join(home_dir, "#{@name}_members.txt")
  end

  def self.instance
    @instance ||= new
    @instance.load_organization_members if @instance.members.empty?
    @instance
  end

  def load_organization_members
    if File.exist?(@members_file_path)
      File.readlines(@members_file_path).each do |line|
        @members.add(line.strip)
      end
    else
      members_url = "https://api.github.com/orgs/#{@name}/members"
      result = GithubClient.fetch_all_pages(members_url)
      @members = result.map { |member| member["login"] }.to_set
      write_members_to_file
    end
  end

  def write_members_to_file
    File.open(@members_file_path, "w") do |file|
      @members.each do |member|
        file.puts member
      end
    end
  end
end
