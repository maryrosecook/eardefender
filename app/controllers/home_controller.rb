class HomeController < ApplicationController

  def index
    username = "maryrosecook"
    user = User.find_by_username(username)
    if !user
      user = User.new_from_request(username)
      user.save()
    end
    
    Lastfming.update_scrobbles(user)
    scrobbles = Choosing.choose_scrobbles(user, "day_of_week")
    most_popular_artists = Choosing.most_popular_artists(scrobbles)
    raise most_popular_artists.inspect
  end
end