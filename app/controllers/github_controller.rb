class GithubController < ApplicationController
  def repo
    begin
      name = params[:repo]
      @repo = Repository.new(name: name).fetch_from_github
      @branches = @repo.fetch_branches_graphql
    rescue => e
      @error = e.message
    end
  end

  def team
    begin
      team = params[:team]
      @members = Member.fetch_team(team)
    rescue => e
      @error = e.message
    end
  end

  def contributions
    begin
      login = params[:login]
      @contributions = Member.fetch_contributions(login)
    rescue => e
      @error = e.message
    end
  end
end
