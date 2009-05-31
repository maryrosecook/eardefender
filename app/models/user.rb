class User < ActiveRecord::Base
  has_many :scrobbles
  
  def self.new_from_request(username)
    user = self.new()
    user.username = username
    return user
  end
end