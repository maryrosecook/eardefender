module Sequencing
  
  def self.next_scrobbles(scrobble)
    next_scrobbles = []
    
    i = 0
    if scrobble
      user_scrobbles = Scrobble.find_ordered_by_date(scrobble.user)
      while i < user_scrobbles.length - 1
        cur_scrobble = user_scrobbles[i]
        if cur_scrobble.artist == scrobble.artist
          same_artist = true
          j = i + 1
          while same_artist && j < user_scrobbles.length  # whizz through following scrobbles until come to new artist
            next_scrobble = user_scrobbles[j]
            same_artist = next_scrobble.artist == cur_scrobble.artist # don't want to keep scrobble if part of same album
            if !same_artist
              next_scrobbles << next_scrobble
            end
            j += 1
          end
        end
      
        i += 1
      end
    end

    return next_scrobbles
  end
end




