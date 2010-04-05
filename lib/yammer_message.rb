module YammerAPI
  class Message < Base
    class << self
      def fetch(access_token, group=nil, id=nil, parameters = {})
        YammerAPI::Base.get(access_token, [group, id], parameters)
      end

      def fetch_latest(access_token)
        fetch(access_token, 'messages')
      end

    end

    def initialize
    end

  end
end
