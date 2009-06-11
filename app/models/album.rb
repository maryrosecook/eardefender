class Album
  attr_accessor :album, :artist, :count
  
  def self.new_one(in_album, in_artist)
    new_album = self.new()
    Util.ne(in_album) ? new_album.album = in_album : new_album.album = ""
    Util.ne(in_artist) ? new_album.artist = in_artist : new_album.artist = ""
    new_album.count = 1
    return new_album
  end
  
  def included_in?(array)
    return find(array, self.album, self.artist)
  end
  
  def self.find(array, in_album, in_artist)
    for array_album in array
      return array_album if array_album.equal?(self.new_one(in_album, in_artist))
    end
    
    return nil
  end
  
  # takes scrobbles and extracts counts, specified aux_info and puts into hash keyed on thing
  def self.scrobbles_to_albums(scrobbles)
    return_albums = []

    all_albums = []
    for scrobble in scrobbles
      if existing_album = Album.find(all_albums, scrobble.album, scrobble.artist)
        existing_album.count += 1
      else
        all_albums << self.new_one(scrobble.album, scrobble.artist)
      end
    end

    # make master list of specific albums or, if none available for an artist, just a non-album-specific suggestion
    all_albums.each { |album| return_albums << album if album.complete? }
    for album in all_albums
      if !album.complete?
        album_for_artist = false
        for return_album in return_albums
          if return_album.artist == album.artist
            album_for_artist = true
            break
          end
        end
        
        return_albums << album if !album_for_artist
      end
    end

    return return_albums
  end
  
  def complete?
    Util.ne(self.artist) && Util.ne(self.album)
  end
  
  def self.uniq(albums)
    unique = []
    for one in albums
      exists = false
      for two in unique
        if one.equal?(two)
          exists = true 
          break
        end
      end
      
      unique << one if !exists
    end
    
    return unique
  end
  
  def equal?(o)
    self.artist == o.artist && (self.album == o.album || (!Util.ne(self.album) && !Util.ne(o.album)))
  end
  
  def partial_equal?(other)
    self.album[0..3] == other.album[0..3] && self.artist[0..3] == other.artist[0..3]
  end
  
  def self.uniq_partial(array)
    unique = []
    array.each { |one| unique << one if !one.include_partial?(unique) }
    return unique
  end
  
  def include_partial?(array)
    exists = false
    for album in array
      if self.partial_equal?(album)
        exists = true 
        break
      end
    end
    
    return exists
  end
end