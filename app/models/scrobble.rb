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
    self.find(:first, :conditions => 'artist = "' + Util.esc_speech(artist) + '"
                                      && track = "' + Util.esc_speech(track) + '"
                                      && date = \'' + DateUtil.str_sql_date_time(date) + '\'
                                      && user_id = ' + user.id.to_s)
  end
  
  def fill_in_album
    if artist && track
      
    end
  end
end