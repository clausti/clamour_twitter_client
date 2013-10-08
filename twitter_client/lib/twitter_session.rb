class TwitterSession
  include Singleton

  CONSUMER_KEY = ENV["CONSUMER_KEY"]
  CONSUMER_SECRET = ENV["CONSUMER_SECRET"]

  CONSUMER = OAuth::Consumer.new(CONSUMER_KEY,
                                 CONSUMER_SECRET,
                                 :site => "https://twitter.com")
   #  get('path', {headers})
   #  get('/people')
   #  get('/people', { 'Accept'=>'application/xml' })
  def self.get(*args)
    self.instance.access_token.get(*args).body
    #returns NET::HTTP object. #body pulls out JSON
  end

  def self.post(*args) # path and optional headers
    self.instance.access_token.post(*args).body
    #returns NET::HTTP object #body pulls out JSON
  end

  attr_reader :access_token

  def initialize
    @access_token = read_or_request_token
  end

  def request_token
    request_token = CONSUMER.get_request_token
                             #method inherited from OAuth::Consumer
    authorize_prompt_url = request_token.authorize_url #another inherited method
    puts "Go here: #{authorize_prompt_url}"
    Launchy.open(authorize_prompt_url)

    puts "Login, and enter your verification code: "
    oauth_verify_code = gets.chomp

    token = request_token.get_access_token(:oauth_verifier => oauth_verify_code)
    File.open("access_token.yaml", "w") { |f| YAML.dump(token, f)}
    return token
  end

  def read_token
    File.open("access_token.yaml") { |f| YAML.load(f) }
  end

  def read_or_request_token
    if File.exist?("access_token.yaml")
      read_token
    else
      request_token
    end
  end

end