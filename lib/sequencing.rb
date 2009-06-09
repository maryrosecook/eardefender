module Sequencing
  
  def self.next_scrobbles(scrobble)
    next_scrobbles = []
    
    i = 0
    user_scrobbles_ordered_by_date = Scrobble.find_ordered_by_date(scrobble.user)
    while i < user_scrobbles_ordered_by_date.length - 1
      cur_scrobble = user_scrobbles_ordered_by_date[i]
      if cur_scrobble.artist == scrobble.artist
        next_scrobble = user_scrobbles_ordered_by_date[i+1]
        if next_scrobble.artist != cur_scrobble.artist # don't want to keep scrobble if part of same album
          Logger.new(STDOUT).error next_scrobble.inspect
          next_scrobbles << next_scrobble
        end
      end
      
      i += 1
    end
    
    return next_scrobbles
  end
end