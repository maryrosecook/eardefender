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
  
  def self.find_latest(user)
    return Scrobble.find(:first, :conditions => "user_id = #{user.id}", :order => 'date desc')  
  end
  
  def self.find_ordered_by_date(user)
    return Scrobble.find(:all, :conditions => "user_id = #{user.id}", :order => 'date asc')  
  end
  
  def self.find_by_user_date(user, start_date, end_date)
    conditions = "1 = 1 "
    conditions += "AND user_id = #{user.id} " if user
    conditions += "AND date > '#{start_date}' AND date < '#{end_date}' " if start_date && end_date
    return self.find(:all, :conditions => conditions)
  end
  
  def already_exists?
    already_exists = true
    already_exists = false if self.new_record? && !Scrobble.find_unique(artist, track, date, user)
    return already_exists
  end
  
  def same?(s)
    s && self.artist == s.artist && self.track == s.track && DateUtil.str_sql_date_time(self.date) == DateUtil.str_sql_date_time(s.date) && self.user.id == s.user.id
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
    end
    
    if self.album != set_album && !(set_album == "" && Util.ne(self.album))
      self.album = set_album
      self.save()
    end
  end
end