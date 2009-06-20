require 'rubygems'
require 'hpricot'
require 'open-uri'

module Lastfming
  
  USE_REAL_DATA = true # switch for using local data instead of real scrobbles.  Probably want this on.
  COMPLETE_SCROBBLE_REINDEX = false # off if want to stop scraping when see scrobble already indexed.  On for complete reindex.
  
  MAX_SCROBBLE_PAGES = 11
  
  MAX_SCRAPING_TIME_BECAUSE_OF_HEROKU_TIMEOUT = 16 # don't update scrobbles for longer than this
  
  def self.update_scrobbles(user)
    if user
      i = 1
      start_time = Time.new
      last_page = false
      new_scrobbles = true
      out_of_time = false
      prev_scrobble = nil
      while i <= MAX_SCROBBLE_PAGES && !last_page && new_scrobbles && !out_of_time # go through max pages until get to captured scrobbles 
        # get page data and extract all track details tds and play date tds
        doc = get_data_page(user, i)
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
            if scrobble = Scrobble.new_from_gathering(artist, track, date, user)
              if !COMPLETE_SCROBBLE_REINDEX && scrobble.already_exists? && !scrobble.same?(prev_scrobble)
                new_scrobbles = false # stop scraping data cause seen this scrobble before, unless doing complete reindex
              else # hasn't already been saved so save it
                scrobble.save() 
              end
            end
          end
          
          # avoid going over fucking Heroku time limit
          out_of_time = (Time.new.tv_sec - start_time.tv_sec) > MAX_SCRAPING_TIME_BECAUSE_OF_HEROKU_TIMEOUT
          break if out_of_time
          
          prev_scrobble = scrobble
          j += 1
        end

        last_page = true if !doc.at("a.nextlink") # no next link so just processed last_page

        i += 1
      end
    end

  end
  
  def self.get_data_page(user, i)
    doc = nil
    if USE_REAL_DATA
      url = "http://www.last.fm/user/#{user.username}/tracks?page=#{i}"
      doc = Hpricot(open(url))
    else # just testing so use local files
      file_str = ""
      File.open("public/test_data/tracks#{i}.html", "r") do |f|
        file_str = f.read
      end
      doc = Hpricot(file_str)
    end

    return doc
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