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
        cookies[:user_id] = user.id.to_s

        Lastfming.update_scrobbles(user)
        scrobbles = Choosing.choose_scrobbles(user, "point_in_week")
        most_popular_artists = Choosing.most_popular("artist", [], scrobbles)
        popular_artist_scrobbles = Choosing.filter_scrobbles_by_artist(most_popular_artists.keys, scrobbles)
        popular_artist_scrobbles.each { |scrobble| scrobble.fill_in_album() }
        @most_popular = Choosing.most_popular("album", ["artist"], scrobbles)
      end
    else # just show form
      # prime old user in form if they exist 
      if cookies[:user_id]
        @user = User.find(cookies[:user_id])
      end
    end
  end
end