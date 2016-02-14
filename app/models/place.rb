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

  def initialize params
    @id = params[:_id].nil?? params[:id] : params[:_id].to_s
    address_components = params[:address_components]
    @address_components = Array.new
    address_components.each do |address_component|
      address_component_instance = AddressComponent.new address_component
      @address_components.push address_component_instance
    end
    @formatted_address = params[:formatted_address]
    @location = Point.new params[:geometry][:location]
  end

  # ﬁnd all documents in the places collection with a matching address_components.short_name
  def self.find_by_short_name short_name
    self.collection.find(:"address_components.short_name" => short_name)
  end

  #accept a Mongo::Collection::View and return a collection of Place instances.
  def self.to_places param
    places = Array.new
    param.each do |place|
      places.push Place.new(place)
    end
    return places
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

    collection.find.aggregate prototype
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
    collection.find.aggregate(prototype).to_a.map {|doc|
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
    collection.find.aggregate(prototype).map { |doc|
      doc[:_id].to_s
    }
  end
end
