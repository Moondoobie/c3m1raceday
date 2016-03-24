class Racer
  include ActiveModel::Model
  attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs
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

  def initialize(params={})
    @id=params[:_id].nil? ? params[:id] : params[:_id].to_s
    @number=params[:number].to_i
    @first_name=params[:first_name]
    @last_name=params[:last_name]
    @gender=params[:gender]
    @group=params[:group]
    @secs=params[:secs].to_i
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

  # Create a class method in the Racer class called find. This method must:
  # accept a single id parameter that is either a string or BSON::ObjectId 
  # Note: it must be able to handle either format
  # find the specific document with that _id
  # return the racer document represented by that id
  def self.find(id)
    object_id = BSON::ObjectId(id)
    result = collection.find(:_id => object_id).first
    return result.nil? ? nil : Racer.new(result)
  end

  def save
      result = self.class.collection.insert_one(
        :_id => @id, 
        :number => @number,
        :first_name => @first_name,
        :last_name => @last_name,
        :gender => @gender,
        :group => @group,
        :secs => @secs
      	)

      @id = result.inserted_id.to_s
  end

  def update(params)
    @number=params[:number].to_i
    @first_name=params[:first_name]
    @last_name=params[:last_name]
    @gender=params[:gender]
    @group=params[:group]
    @secs=params[:secs].to_i

    params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
    self.class.collection.find(:_id => BSON::ObjectId.from_string(self.id)).replace_one({
      number: @number,
      first_name: @first_name,
      last_name: @last_name,
      gender: @gender,
      group: @group,
      secs: @secs
    })

    # find the racer associated with the current @id instance variable in the database
    # update the racer with the supplied values – replacing all values

  end

  def destroy
    self.class.collection.find(:number => @number).delete_one()

    # find the racer associated with the current @number instance variable in the database
    # remove that instance from the database

  end

  def persisted?
    !@id.nil?
  end

  def created_at
    nil
  end

  def updated_at
    nil
  end

  def self.paginate(params)
    page=(params[:page] || 1).to_i
    limit=(params[:per_page] || 30).to_i
    skip=(page-1)*limit

    racers=[]
    
    #find racer docs
    #self.collection.find.sort({:number => 1}).each { |r| pp r }
    self.all({}, {:number => 1}, skip, limit).each do |doc|
      racers << Racer.new(doc)
    end
    
    total=self.all({}, {:number => 1}, 0, 1).count
    
    WillPaginate::Collection.create(page, limit, total) do |pager|
      pager.replace(racers)
    end

    # find all racers sorted by number assending.
    # limit the results to page and limit values. - project only these two?

    # convert each document hash to an instance of a Racer class
    # Return a WillPaginate::Collection with the page, limit, and total values 
    # filled in – as well as the page worth of data.

  end




end
