class Point
  include Mongoid::Document

  attr_accessor :longitude, :latitude;

  def initialize hash
    if hash.has_key? :coordinates
      @longitude = hash[:coordinates][0]
      @latitude = hash[:coordinates][1]
    else
      @latitude = hash[:lat]
      @longitude = hash[:lng]
    end
  end

  def to_hash
    {"type":"Point", "coordinates":[ @longitude, @latitude]}
  end
end
