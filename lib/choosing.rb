module Choosing

  DEFAULT_TIME_HOURS_EITHER_SIDE = 1
  NUM_MOST_POPULAR_ARTISTS = 3
  NUM_MOST_POPULAR = 3

  
  def self.choose_scrobbles(scrobbles, criteria_method)
    return class_eval(criteria_method + "(scrobbles)")
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
  
  def self.filter_scrobbles_by_artist(artists, scrobbles)
    return_scrobbles = []
    scrobbles.each { |scrobble| return_scrobbles << scrobble if artists.include?(scrobble.artist) }
    return return_scrobbles
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
  
  def self.most_popular(thing, aux_infos, scrobbles)
    most_popular = {}
    things = {}
    for scrobble in scrobbles
      if Util.ne(eval("scrobble.#{thing}"))
        count = 0 if !things.has_key?(eval("scrobble.#{thing}"))
        count += 1
        
        return_thing = {}
        return_thing["count"] = count
        for aux_info in aux_infos
          return_thing[aux_info] = eval("scrobble.#{aux_info}")
        end

        things[eval("scrobble.#{thing}")] = return_thing
      end
    end

    things_by_popularity = things.keys.sort { |x,y| things[y]["count"] <=> things[x]["count"] }
    i = 0
    while i < things_by_popularity.length && i < NUM_MOST_POPULAR
      most_popular[things_by_popularity[i]] = things[things_by_popularity[i]]
      i += 1
    end
    
    return most_popular
  end
  
  def self.albums_from_scrobbles(scrobbles)
    most_popular_artists = Choosing.most_popular("artist", [], scrobbles)
    popular_artist_scrobbles = Choosing.filter_scrobbles_by_artist(most_popular_artists.keys, scrobbles)
    popular_artist_scrobbles.each { |scrobble| scrobble.fill_in_album() }
    return Choosing.most_popular("album", ["artist"], scrobbles)
  end
end