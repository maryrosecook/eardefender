class HomeController < ApplicationController

  def index
    if request.post? # make some suggestions
      # set up user
      user = User.find_by_username(params[:username])
      if !user
        user = User.new_from_request(params[:username])
        user.save()
      end
      cookies[:user_id] = user.id.to_s

      # get user's latest scrobbles
      Lastfming.update_scrobbles(user)

      # get all time most popular albums for current time of current day of week over various time periods
      @point_in_week_albums = []
      @point_in_week_albums += user_time_period_scrobbles(user, nil, nil, "point_in_week")
      @point_in_week_albums += user_time_period_scrobbles(user, 4.weeks.ago, 2.weeks.ago, "point_in_week")
      @point_in_week_albums += user_time_period_scrobbles(user, 8.weeks.ago, 4.weeks.ago, "point_in_week")
      @point_in_week_albums = Album.uniq_partial(@point_in_week_albums)
      
      # get albums most often played after most recently scrobbled album
      @latest_scrobble = Scrobble.find_latest(user)
      raise @latest_scrobble.inspect
      next_scrobbles = Sequencing.next_scrobbles(@latest_scrobble)
      all_albums = Choosing.choose(next_scrobbles)
      @seqencing_albums = Choosing.most_popular(all_albums, 3)
    else # just show user selection form
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