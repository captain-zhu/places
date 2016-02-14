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
    @id = params[:_id].to_s
    address_components = params[:address_components]
    @address_components = Array.new
    address_components.each do |address_component|
      address_component_instance = AddressComponent.new address_component
      @address_components.push address_component_instance
    end
    @formatted_address = params[:formatted_address]
    @location = Point.new params[:geometry][:location]
  end


end
