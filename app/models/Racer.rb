class Racer
  #MONGO_URL='mongodb://localhost:27017'
  #MONGO_DATABASE='raceday_development'

  RACE_COLLECTION='racers'

  # helper function to obtain connection to server and 
  # set connection to use specific DB
  def self.mongo_client
    #url=ENV['MONGO_URL'] ||= MONGO_URL
    #database=ENV['MONGO_DATABASE'] ||= MONGO_DATABASE 
    #db = Mongo::Client.new(url)
    #@@db=db.use(default)

    Mongoid::Clients.default
    
  end

  # helper method to obtain collection used to make race results.
  def self.collection
    collection=ENV['RACE_COLLECTION'] ||= RACE_COLLECTION
    return mongo_client[collection]
  end

  def self.all(prototype={}, sort={:number=>1}, offset=0, limit=nil)
    # default for sort is ascending
    # sort, skip, and limit are optional
    # skip default is 0, limit default is nil

    result=collection.find(prototype)
          .sort(sort)
          .skip(offset)
    result=result.limit(limit) if !limit.nil?
    # add projection later?
    # .projection({_id:true, city:true, state:true, pop:true})

    return result
  end





end
