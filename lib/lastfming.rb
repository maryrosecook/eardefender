require 'rubygems'
require 'hpricot'
require 'open-uri'

module Lastfming
  
  MAX_PAGES = 11
  CANNED_SEARCH = "Last.fm username"
  
  def self.update_scrobbles(user)
    if user
      i = 1
      last_page = false
      new_scrobbles = true
      while i <= MAX_PAGES && !last_page && new_scrobbles # go through all pages to explore until get to captured scrobbles
        url = "http://www.last.fm/user/#{user.username}/tracks?page=#{i}"
        doc = Hpricot(open(url))
        
        # file_str = ""
        # File.open("public/tracks#{i}.html", "r") do |f|
        #   file_str = f.read
        # end
        # doc = Hpricot(file_str)
      
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
            if scrobble
              if scrobble.already_exists?
                new_scrobbles = false # stop scraping data
              else # hasn't already been saved so save it
                scrobble.save() 
              end
            end
          end
        
          j += 1
        end

        last_page = true if !doc.at("a.nextlink") # no next link so just processed last_page
        i += 1
      end
    end
  end
  
  LAST_FM_API_KEY = "0fe92bb2a3b1e5b714cc39e2df8da14f"
  def self.get_album(artist, track)
    album = nil
    url = APIUtil.safely_parse_url("http://ws.audioscrobbler.com/2.0/?method=track.getinfo&api_key=#{LAST_FM_API_KEY}&artist=#{artist}&track=#{track}")
    begin
      doc = open(url.to_s) do |f|
        Hpricot.XML(f)
      end

      if xml_data = doc.at("lfm/track/album/title")
        album = xml_data.inner_text
      end
    rescue
    end
    
    return album
  end
end