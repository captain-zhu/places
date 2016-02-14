class Photo
  include Mongoid::Document

  attr_accessor :id, :location
  attr_writer :contents

  # returns a MongoDB Client from Mongoid referencing the default database from the config/mongoid.yml ﬁle
  def mongo_client
    Mongoid::Clients.default
  end




end
