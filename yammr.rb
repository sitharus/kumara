require 'oauth'

module Yammr
  path = File.dirname(File.expand_path(__FILE__));
  require '#{path}/'

  class Client

    def initialize
    end

    def user_authenticated?
      not @user.nil?
    end

    def start_oauth(username)
      @consumer = OAuth::Consumer.new(
                                     Yamr::OAUTH_APP_KEY,
                                     Yamr::OAUTH_APP_SECRET,
                                     {:site => "https://www.yammer.com"}
                                     )

      @request_token = consumer.get_request_token
      @request_token.authorize_url
    end

    def finish_oauth(auth_code)
      @access_token = request_token.get_access_token(:oauth_verifier => auth_code)

      #access_token.token
      #access_token.secret

    end

    def get_messages()

    end
  end
  
end
