require 'rubygems'
require 'hpricot'
require 'open-uri'

module Lastfming
  
  MAX_PAGES = 30
  
  LAST_FM_API_KEY
  
  def self.update_scrobbles(user)
    if user
      i = 1
      last_page = false
      new_scrobbles = true
      while i <= MAX_PAGES && !last_page && new_scrobbles # go through all pages to explore until get to captured scrobbles
        #url = "http://www.last.fm/user/#{user.username}/tracks?page={i}"
        #doc = Hpricot(open(url))
        
        file_str = ""
        File.open("public/tracks#{i}.html", "r") do |f|
          file_str = f.read
        end
        #raise file_str
        doc = Hpricot(file_str)
      
        # get all track details tds and play date tds
        tracks_raw = doc.search("td.subjectCell")
        dates_raw = doc.search("td.dateCell")
      
        # whizz through all tracks on this page
        j = 0
        for track_raw in tracks_raw
          artist_and_track = track_raw.search("//a")
          artist = artist_and_track[0].inner_text if artist_and_track[0]
          track = artist_and_track[1].inner_text if artist_and_track[1]
        
          if date_raw = dates_raw[j] # got date for this track play
            date = date_raw.at("abbr")["title"]
            scrobble = Scrobble.new_from_gathering(artist, track, date, user)
            scrobble.save() if scrobble && !scrobble.already_exists? # hasn't already been saved so save it
            new_scrobbles = false if scrobble.already_exists?
          end
        
          j += 1
        end
      
        last_page = true if !doc.at("a.nextlink") # no next link so just processed last_page
        i += 1
      end
    end
  end
  
  def self.get_track_info
    APIUtil.get_request("http://ws.audioscrobbler.com/2.0/?method=track.getinfo&api_key=#{}&artist=cher&track=believe")
  end
end