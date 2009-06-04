class HomeController < ApplicationController

  def index
    if request.post?
      @suggestions = {} # final array of suggestions of albums (with artist data and frequency of track plays)

      # set up user
      user = User.find_by_username(params[:username])
      if !user
        user = User.new_from_request(params[:username])
        user.save()
      end
      cookies[:user_id] = user.id.to_s

      Lastfming.update_scrobbles(user)

      # get all time most popular albums for current time of current day of week
      Util.add_to_hash(@suggestions, user_time_period_scrobbles(user, nil,  nil, "point_in_week"))
      
      # get most popular albums for current time of current day a while ago
      Util.add_to_hash(@suggestions, user_time_period_scrobbles(user, 4.weeks.ago, 2.weeks.ago, "point_in_week"))
      
      @albums_by_artist = @suggestions.keys.sort { |x,y| @suggestions[x]["artist"] <=> @suggestions[y]["artist"] }
    else # just show form
      # prime old user in form if they exist 
      if cookies[:user_id]
        if user = User.find(cookies[:user_id])
          @username = user.username
        end
      end
    end
  end
  
  private
    
    def user_time_period_scrobbles(user, start_date, end_date, method)
      user_time_period_scrobbles = Scrobble.find_by_user_date(user, start_date, end_date)
      time_period_scrobbles = Choosing.choose_scrobbles(user_time_period_scrobbles, method)
      return Choosing.albums_from_scrobbles(time_period_scrobbles)
    end
end