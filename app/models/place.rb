class Place
  include Mongoid::Document
  require 'json'

  attr_accessor :id, :formatted_address, :location, :address_components

  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    self.mongo_client['places']
  end

  #load a JSON document with places into the place collection
  def self.load_all file
    to_parse_file = File.read file
    data_hash = JSON.parse to_parse_file
    self.collection.insert_many(data_hash)
  end

  def initialize params={}
    @id = params[:_id].nil?? params[:id] : params[:_id].to_s
    @address_components = params[:address_components].map { |a| AddressComponent.new(a) } unless params[:address_components].nil?
    @formatted_address = params[:formatted_address]
    @location = Point.new params[:geometry][:geolocation]
  end

  # ﬁnd all documents in the places collection with a matching address_components.short_name
  def self.find_by_short_name short_name
    self.collection.find(:"address_components.short_name" => short_name)
  end

  #accept a Mongo::Collection::View and return a collection of Place instances.
  def self.to_places params
    params.map do |param|
      Place.new param
    end
  end
  # return an instance of Place for a supplied id
  def self.find id
    object_id = BSON::ObjectId.from_string id
    document = self.collection.find(:_id => object_id).first
    return document.nil?? nil : Place.new(document)
  end

  # return an instance of all documents as Place instances
  def self.all offset=0, limit=0
    self.to_places self.collection.find().skip(offset).limit(limit)
  end

  # delete the document associtiated with its assigned id.
  def destroy
    object_id = BSON::ObjectId.from_string(@id)
    self.class.collection.find(:_id => object_id).delete_one
  end

  # returns a collection of hash documents with address_components and their associated _id,
  # formatted_address and location properties.
  def self.get_address_components sort=nil, offset=nil, limit=nil
    prototype = [
        {
            :$unwind => '$address_components'
        },
        {
            :$project => {
                :address_components => 1,
                :formatted_address => 1,
                :'geometry.geolocation' => 1
            }
        }
    ]

    prototype << {:$sort => sort} if !sort.nil?
    prototype << {:$skip => offset} if !offset.nil?
    prototype << {:$limit => limit} if !limit.nil?

    self.collection.find.aggregate prototype
  end

  # a distinct collection of country names (long_names)
  def self.get_country_names
    prototype = [
        {
            :$project => {
                :_id=>0,
                :"address_components.long_name"=>1,
                :"address_components.types"=>1
            }
        },
        {
           :$unwind => "$address_components"
        },
        {
            :$match => {
                :"address_components.types" => "country"
            }
        },
        {
            :$group => {
                :_id => "$address_components.long_name"
            }
        }
    ]
    self.collection.find.aggregate(prototype).to_a.map {|doc|
      doc[:_id]
    }
  end

  # return the id of each document in the places collection that has
  # an address_component.short_name of type country
  # and matches the provided parameter
  def self.find_ids_by_country_code country_code
    prototype = [
        {
            :$match => {
                :'address_components.types' => 'country',
                :'address_components.short_name' => country_code
            }
        },
        {
            :$project => {
                :_id => 1
            }
        }
    ]
    self.collection.find.aggregate(prototype).map { |doc|
      doc[:_id].to_s
    }
  end

  # create a 2dsphere index to your collection for the geometry.geolocation property.
  def self.create_indexes
    self.collection.indexes.create_one(:"geometry.geolocation" => Mongo::Index::GEO2DSPHERE)
  end

  # remove a 2dsphere index to your collection for the geometry.geolocation property.
  def self.remove_indexes
    self.collection.indexes.drop_one('geometry.geolocation_2dsphere')
  end

  # returns places that are closest to provided Point.
  def self.near point, max_meters=nil
    self.collection.find(:"geometry.geolocation" => {
        :$near => {
            :$geometry => point.to_hash,
            :$maxDistance => max_meters
        }
    })
  end

  # wraps the class near method
  def near max_meters=nil
    documents = self.class.near(@location, max_meters)
    self.class.to_places(documents)
  end

  # return a collection of Photos that have been associated with the place
  def photos offset=0, limit=nil
    docs = Photo.find_photos_for_place(@id).skip(offset)
    docs.limit(limit) if !limit.nil?
    docs.map { |doc|
      Photo.new doc
    }
  end

end
