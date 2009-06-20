module Choosing

  DEFAULT_TIME_HOURS_EITHER_SIDE = 1
  NUM_MOST_POPULAR = 3
  NUM_TOP_ARTISTS = 15
  
  TIME_FILLING_IN_ALBUMS_FOR_HEROKU = 8
  
  def self.choose_scrobbles(scrobbles, criteria_method)
    return class_eval(criteria_method + "(scrobbles)")
  end
  
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
  
  # pick most popular NUM_MOST_POPULAR things from passed scrobbles
  def self.most_popular(albums, num)
    most_popular = []
    
    i = 0
    albums_by_popularity = albums.sort { |x,y| y.count <=> x.count }
    while i < albums_by_popularity.length && most_popular.length < num
      most_popular << albums_by_popularity[i]
      i += 1
    end
    
    return most_popular
  end
  
  # takes scrobbles and extracts counts, specified aux_info and puts into hash keyed on thing
  def self.scrobbles_to_things(thing, aux_infos, scrobbles)
    things = {}
    for scrobble in scrobbles
      thing_name = eval("scrobble.#{thing}")
      if Util.ne(thing_name)
        count = 0 if !things.has_key?(thing_name)
        count += 1
        
        return_thing = {}
        return_thing["count"] = count
        for aux_info in aux_infos
          return_thing[aux_info] = eval("scrobble.#{aux_info}")
        end

        things[thing_name] = return_thing
      end
    end
    
    return things
  end
  
  # choose some albums to suggest from scrobbles passed
  def self.choose(scrobbles)
    albums_with_aux_info = []
    
    artists = Choosing.scrobbles_to_things("artist", [], scrobbles)
    artist_name_freq_array = []
    for artist_name in artists.keys
      count = artists[artist_name]["count"]
      if count > 1 && Util.ne(artist_name)
        (0..count).each { |i| artist_name_freq_array << artist_name }
      end
    end

    chosen_artists = {}
    for i in (0..NUM_TOP_ARTISTS)
      artist_name = Util.rand_el(artist_name_freq_array)
      chosen_artists[artist_name] = artists[artist_name]
    end

    popular_artist_scrobbles = Choosing.filter_scrobbles_by_artist(chosen_artists.keys, scrobbles)
    
    start = Time.new.tv_sec
    for scrobble in popular_artist_scrobbles
      scrobble.fill_in_album()
      break if (Time.new.tv_sec - start) > TIME_FILLING_IN_ALBUMS_FOR_HEROKU
    end
    
    albums = Album.scrobbles_to_albums(popular_artist_scrobbles)
    return Choosing.most_popular(albums, NUM_MOST_POPULAR)
  end
end