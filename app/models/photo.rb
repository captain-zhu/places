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
    @place = hash[:metadata][:place] if !hash[:metadata].nil?
  end

  # return true if the instance has been created within GridFS
  def persisted?
    return !@id.nil?
  end

  # store a new instance into GridFS
  def save
    if !self.persisted?
      gps = EXIFR::JPEG.new(@contents).gps
      description = {}
      description[:content_type] = 'image/jpeg'
      description[:metadata] = {}
      @location = Point.new(:lng => gps.longitude,  :lat => gps.latitude)
      description[:metadata][:location] = @location.to_hash
      description[:metadata][:place] = @place

      if @contents
        @contents.rewind
        grid_file = Mongo::Grid::File.new(@contents.read, description)
        id = self.mongo_client.database.fs.insert_one grid_file
        @id = id.to_s
      end
    else
      self.class.mongo_client.database.fs.find(:_id => BSON::ObjectId(@id))
          .update_one(:$set => {
              :metadata => {
                  :location => @location.to_hash,
                  :place => @place
              }
          })
    end
  end

  # return a collection of Photo instances representing each ﬁle returned from the database
  def self.all skip=0, limit=nil
    docs = self.mongo_client.database.fs.find().skip(skip)
    docs = docs.limit(limit) if !limit.nil?
    docs.map { |doc|
      Photo.new doc
    }
  end

  # return an instance of a Photo based on the input id
  def self.find id
    id = BSON::ObjectId.from_string id if id.class==String
    doc =self.mongo_client.database.fs.find(:_id => id).first
    return doc.nil?? nil : Photo.new(doc)
  end

  # Create a custom getter for contents that will return the data contents of the ﬁle
  def contents
    doc = self.class.mongo_client.database.fs.find_one(:_id => BSON::ObjectId(@id))
    if doc
      buffer = ""
      doc.chunks.reduce([]) do |x, chunk|
        buffer << chunk.data.data
      end
      return buffer
    end
  end

  # delete the ﬁle and contents associated with the ID of the object instance
  def destroy
    self.class.mongo_client.database.fs.find(:_id => BSON::ObjectId(@id)).delete_one
  end

  # will return the _id of the document within the places collection.
  def find_nearest_place_id max_meters
    place = Place.near(@location, max_meters).limit(1).projection(:_id=>1).first
    return place.nil?? nil : place[:_id]
  end

  # place attr get method
  def place
    Place.find(@place.to_s) if !@place.nil?
  end

  # place attr set method
  def place= place
    if place.class == Place
      @place = BSON::ObjectId.from_string(place.id)
    elsif place.class == String
      @place = BSON::ObjectId.from_string(place)
    else
      @place = place
    end
  end

  # accepts the BSON::ObjectId of a Place and returns a collection view of photo documents that
  # have the foreign key reference.
  def self.find_photos_for_place id
    id = BSON::ObjectId.from_string(id) if id.class==String
    self.mongo_client.database.fs.find(:"metadata.place" => id)
  end

end
