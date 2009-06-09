module Util

  def self.ne(str)
    str && str != ""
  end
  
  def self.strip_html(str)
    str.gsub(/<\/?[^>]*>/, "")
  end
  
  def self.esc_speech(str)
    str = str.gsub(/"/, '\"')
  end
  
  def self.esc_apos(str)
    return_str = str
    return_str = return_str.gsub(/'/, "\\\\'")
    return return_str
  end
  
  # adds additions to hash.  Overwrites existing key entries w/ new ones
  def self.add_to_hash(hash, additions)
    additions.keys.each { |addition_key| hash[addition_key] = additions[addition_key] }
    return hash
  end
  
  def self.uniq_partial(array)
    unique = []
    array.each { |one| unique << one if !include_partial?(one, unique) }
    return unique
  end
  
  def self.include_partial?(one, array)
    exists = false
    for two in array
      if one[0..3] == two[0..3]
        exists = true 
        break
      end
    end
    
    return exists
  end
  
  # shorts passed str to passed word_count
  def self.truncate(str, word_count, elipsis)
    words = str.split()
    truncated_str = str.split[0..(word_count-1)].join(" ")
    if elipsis && words.length() > word_count
      truncated_str += "..."
    end
    
    truncated_str
  end
  
  # returns random element of array
  def self.rand_el(array)
    el = nil
    el = array[rand()*(array.length-1)] unless !array || array.length < 1
    
    el
  end
  
  def self.scrub_fastidious_entities(str)
    str.gsub(/&#8217;/, "'").gsub(/&amp;/, "&")
  end
  
  def self.parse_js_response(request)
    word_raw = request.raw_post || request.query_string
    word_raw = word_raw.gsub(/(.*)authenticity_token.*/, "\\1")
    word_raw.gsub(/&/, "")
  end
  
  def self.items_occurring_more_than_once(items)
    ret_items_occurring_more_than_once = []
    for item_a in items
      occurrences = 0
      items.each {|item_b| occurrences += 1 if item_a == item_b }
      ret_items_occurring_more_than_once << item_a if occurrences > 1
    end
    
    ret_items_occurring_more_than_once.uniq()
  end
end