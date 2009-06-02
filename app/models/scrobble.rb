class Scrobble < ActiveRecord::Base
  belongs_to :user
  
  def self.new_from_gathering(artist, track, date, user)
    scrobble = nil
    if Util.ne(artist) && Util.ne(track) && Util.ne(date) && user
      scrobble = self.new()
      scrobble.artist = artist
      scrobble.track = track
      scrobble.date = date
      scrobble.date = scrobble.date.utc
      scrobble.user = user
    end
    
    return scrobble
  end
  
  def already_exists?
    already_exists = true
    if self.new_record?
      if !Scrobble.find_unique(artist, track, date, user)
        already_exists = false
      end
    end
    
    return already_exists
  end
  
  def self.find_unique(artist, track, date, user)
    self.find(:first, :conditions =>  "artist = '#{Util.esc_apos(artist)}' " + 
                                      "AND track = '#{Util.esc_apos(track)}' " + 
                                      "AND date = '#{DateUtil.str_sql_date_time(date)}' " +
                                      "AND user_id = #{user.id.to_s} ")
  end
  
  def fill_in_album
    set_album = ""
    if artist && track && !album
      found_album = Lastfming.get_album(artist, track)
      set_album = found_album if found_album
      Logger.new(STDOUT).error artist + " " + track
    end
    
    if self.album != set_album && !(set_album == "" && Util.ne(self.album))
      self.album = set_album
      self.save()
    end
  end
end