class HomeController < ApplicationController

  def index
    if request.post?
      @most_popular = {}
      if params[:username] != Lastfming::CANNED_SEARCH # check not searching for search box prompt
        # set up user
        user = User.find_by_username(params[:username])
        if !user
          user = User.new_from_request(username)
          user.save()
        end
        session[:user_id] = user.id

        Lastfming.update_scrobbles(user)
        scrobbles = Choosing.choose_scrobbles(user, "day_of_week")
        @most_popular = Choosing.most_popular_artists(scrobbles)
      end
    else # just show form
      # prime old user in form if they exist 
      if session[:user_id]
        @user = User.find(session[:user_id])
      end
    end
  end
end