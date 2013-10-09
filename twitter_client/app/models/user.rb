class User < ActiveRecord::Base
  attr_accessible :twitter_user_id, :screen_name

  validates :twitter_user_id, :uniqueness => true, :presence => true
  validates :screen_name, :uniqueness => true, , :presence => true

  def self.fetch_by_screen_name(screen_name)
    get_user_url = Addressable::URI.new(
                     :scheme => "https",
                     :host => "api.twitter.com",
                     :path => "/1.1/users/show.json",
                     :query_values => { :screen_name => screen_name } ).to_s

    user_as_json = TwitterSession.get(get_user_url)
    self.parse_twitter_params(user_as_json)
  end

  def self.parse_twitter_params(user_as_json)
    screen_name = user_as_json["screen_name"]
    twitter_user_id = user_as_json["id_str"]

    User.create({:screen_name => screen_name, :twitter_user_id => twitter_user_id})
  end

  has_many(:statuses,
           :foreign_key => :twitter_user_id,
           :primary_key => :twitter_user_id,
           :class_name => "Status")

  def sync_statuses
    statuses = Status.fetch_statuses_for_user(@twitter_user_id)
    statuses.each do |status|
      if status.persisted?
        next
      else
        status.save!
      end
    end
  end

end
