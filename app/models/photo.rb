class Photo
  include Mongoid::Document
  attr_accessor :id, :location
  attr_writer :contents

  # returns a MongoDB Client from Mongoid referencing the default database from the config/mongoid.yml ﬁle
  def mongo_client
    Mongoid::Clients.default
  end

  def initialize hash={}
    @id = hash[:_id].to_s unless hash[:_id].nil?
    @location = Point.new hash[:metadata][:location] unless hash[:metadata].nil?
  end




end
