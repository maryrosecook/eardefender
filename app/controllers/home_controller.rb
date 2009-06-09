class HomeController < ApplicationController

  def index
    if request.post?
      @point_in_week_suggestions = {} # final array of suggestions of albums (with artist data and frequency of track plays)

      # set up user
      user = User.find_by_username(params[:username])
      if !user
        user = User.new_from_request(params[:username])
        user.save()
      end
      cookies[:user_id] = user.id.to_s

      # get user's latest scrobbles
      Lastfming.update_scrobbles(user)

      # get all time most popular albums for current time of current day of week over various periods
      Util.add_to_hash(@point_in_week_suggestions, user_time_period_scrobbles(user, nil,  nil, "point_in_week"))
      Util.add_to_hash(@point_in_week_suggestions, user_time_period_scrobbles(user, 4.weeks.ago, 2.weeks.ago, "point_in_week"))
      Util.add_to_hash(@point_in_week_suggestions, user_time_period_scrobbles(user, 8.weeks.ago, 4.weeks.ago, "point_in_week"))
      @point_in_week_albums_by_artist = @point_in_week_suggestions.keys.sort { |x,y| @point_in_week_suggestions[x]["artist"] <=> @point_in_week_suggestions[y]["artist"] }
      
      # get albums most often played after most recently scrobbled album
      @latest_scrobble = Scrobble.find_latest(user)
      next_scrobbles = Sequencing.next_scrobbles(@latest_scrobble)
      @seqencing_suggestions = Choosing.most_popular("album", ["artist"], next_scrobbles, 3)
      @sequencing_albums_by_artist = @seqencing_suggestions.keys.sort { |x,y| @seqencing_suggestions[x]["artist"] <=> @seqencing_suggestions[y]["artist"] }
      
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
      return Choosing.choose(time_period_scrobbles)
    end
end