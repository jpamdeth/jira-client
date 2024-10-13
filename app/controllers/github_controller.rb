class GithubController < ApplicationController
  def repo
    begin
      name = params[:repo]
      @repo = Repository.new(name: name).fetch_from_github
      @branches = @repo.fetch_branch_data
    rescue => e
      @error = e.message
    end
  end

  def team
    begin
      org = params[:org]
      team = params[:team]
      @members = Member.fetch_from_github(org, team)
    rescue => e
      @error = e.message
    end
  end
end
