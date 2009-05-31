module Choosing

  DEFAULT_TIME_HOURS_EITHER_SIDE = 0
  NUM_MOST_POPULAR_ARTISTS = 3

  def self.choose_scrobbles(user, method)
    return class_eval(method + "(user.scrobbles)")
  end

  ### methods
  
  def self.day_of_week(scrobbles)
    return filter_day_of_week(scrobbles, Time.new)
  end
  
  def self.time_of_day(scrobbles)
    return filter_time_of_day(scrobbles, Time.new, DEFAULT_TIME_HOURS_EITHER_SIDE)
  end
  
  def self.point_in_week(scrobbles)
    filtered_scrobbles = day_of_week(scrobbles)
    filtered_scrobbles = time_of_day(scrobbles)
    return filtered_scrobbles
  end
  
  def self.filter_day_of_week(scrobbles, target_date)
    filtered_scrobbles = []
    target_weekday_name = DateUtil.weekday_name(target_date)
    scrobbles.each { |scrobble| filtered_scrobbles << scrobble if target_weekday_name == DateUtil.weekday_name(scrobble.date) }
    return filtered_scrobbles
  end
  
  def self.filter_time_of_day(scrobbles, target_date, hours_either_side)
    filtered_scrobbles = []
    target_hour = DateUtil.hour(target_date).to_i
    for scrobble in scrobbles
      scrobble_hour = DateUtil.hour(scrobble.date).to_i
      early_bound = target_hour - hours_either_side
      late_bound = target_hour + hours_either_side

      if early_bound <= scrobble_hour && late_bound >= scrobble_hour
        filtered_scrobbles << scrobble
      end
    end
    
    return filtered_scrobbles
  end
  
  def self.most_popular_artists(scrobbles)
    most_popular_artists = {}
    artists = {}
    for scrobble in scrobbles
      artists[scrobble.artist] = 0 if !artists.has_key?(scrobble.artist)
      artists[scrobble.artist] += 1
    end

    artists_by_popularity = artists.keys.sort { |x,y| artists[y] <=> artists[x] }
    i = 0
    while i < artists_by_popularity.length && i < NUM_MOST_POPULAR_ARTISTS
      most_popular_artists[artists_by_popularity[i]] = artists[artists_by_popularity[i]]
      i += 1
    end
    
    return most_popular_artists
  end
end