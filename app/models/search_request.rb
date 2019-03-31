# Class encapsulating search requests.
class SearchRequest
  # Minimum query length, or we return an empty result
  MIN_QUERY_LENGTH = 3

  attr_accessor :query, :seq, :tag, :nwlat, :nwlng, :selat, :selng

  def initialize; end

  def self.from_request(rparams)
    obj = new
    obj.query = rparams[:query]
    obj.seq = rparams[:seq]
    obj.tag = rparams[:tag]
    obj.nwlat = rparams[:nwlat]
    obj.nwlng = rparams[:nwlng]
    obj.selat = rparams[:selat]
    obj.selng = rparams[:selng]
    obj
  end

  # Check the query string to make sure it is not blank (null, empty string, or ' ')
  # and make sure it is at least 3 characters
  def valid?
    isValid = true
    isValid &&= !query.blank?
    isValid &&= query.length >= MIN_QUERY_LENGTH
    unless isValid
      isValid ||= !nwlat.nil? && !nwlng.nil? && !selat.nil? && !selng.nil?
    end
    isValid
  end

  # This subclass is used to auto-generate the RESTful data structure.  It is generally not useful for internal Ruby usage
  #  but must be included for full RESTful functionality.
  class Entity < Grape::Entity
    expose :query, documentation: { type: 'String', desc: 'Search Query text.' }
    expose :seq, documentation: { type: 'Integer', desc: 'Sequence value passed from client through to the SearchResult. For client sequencing usage' }
    expose :tag, documentation: { type: 'String', desc: 'Refine search by specified tag.' }
    expose :nwlat, documentation: { type: 'Float', desc: 'Geograpical northwest latitude coordinate' }
    expose :nwlng, documentation: { type: 'Float', desc: 'Geograpical northwest longitude coordinate' }
    expose :selat, documentation: { type: 'Float', desc: 'Geograpical southeast latitude coordinate' }
    expose :selng, documentation: { type: 'Float', desc: 'Geograpical southeast longitude coordinate' }
  end
end
