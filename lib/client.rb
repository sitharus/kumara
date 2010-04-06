require 'rubygems'
require 'oauth'

module YammerAPI
  class Client
    def initialize(app_key, app_secret)
      @consumer = OAuth::Consumer.new(app_key, app_secret,
                                      {:site => "https://www.yammer.com"}
                                      )
    end

    def user_authenticated?
      not @user.nil?
    end

    def access_token
      @access_token.token
    end

    def access_token_secret
      @access_token.secret
    end

    def set_credentials(token, secret)
      @access_token = OAuth::AccessToken.new(@consumer, token, secret)
    end

    def start_oauth
      @request_token = @consumer.get_request_token
      @request_token.authorize_url
    end

    def finish_oauth(auth_code)
      @access_token = @request_token.get_access_token(:oauth_verifier => auth_code)
    end

    def fetch_messages()
      Message.fetch_latest(@access_token)
    end
  end
  
end
