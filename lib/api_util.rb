module APIUtil

  # gets xml from passed url
  def self.get_request(url)
    response = nil
    url = make_url_safe(url)
    begin
      Timeout::timeout(2) do
        resp = Net::HTTP.get_response(URI.parse(url)) # get_response takes an URI object
        response = resp.body
      end
    rescue Timeout::Error
    rescue
    end
  
    response
  end
end