class Status < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :twitter_user_id, :twitter_status_id, :body

  validates :twitter_status_id, :uniqueness => true, :presence => true
  validates :twitter_user_id, :presence => true
  validates :body, :presence => true


  def self.fetch_statuses_for_user(twitter_user_id)
    get_statuses_url = Addressable::URI.new(
                         :scheme => "https",
                         :host => "api.twitter.com",
                         :path => "/1.1/statuses/user_timeline.json",
                         :query_values => { :user_id => twitter_user_id }
                         ).to_s

    json_statuses = TwitterSession.get(get_statuses_url) #array or something
    status_objects = []

    json_statuses.each do |status|
      status_objects << self.retrieve_or_create(status)
    end

    status_objects
  end


  def self.retrieve_or_create(json_status)
    status = Status.find_by_twitter_status_id(json_status["id_str"])

    if status
      status
    else
      status = self.parse_twitter_status(json_status)
    end
  end

  def self.parse_twitter_status(json_status) #received from where?
    twitter_status_id = json_status["id_str"]
    twitter_user_id = json_status["user"]["id_str"]
    body = json_status["text"]
    Status.create({:twitter_user_id => twitter_user_id,
                  :twitter_status_id => twitter_status_id,
                  :body => body})
  end

  belongs_to(:user,
             :foreign_key => :twitter_user_id,
             :primary_key => :twitter_user_id,
             :class_name => "User")


end
