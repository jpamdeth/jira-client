class GithubController < ApplicationController

  def index
    render :github_form
  end

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
    if params[:team].blank?
      render :team_form
    else
      begin
        team = params[:team]
        @members = Organization.fetch_team(team)
      rescue => e
        @error = e.message
      end
    end
  end

  def contributions
    begin
      login = params[:login]
      @name = Member.fetch(login).name
      @contributions = Member.fetch_contributions(login)
    rescue => e
      @error = e.message
    end
  end
end
