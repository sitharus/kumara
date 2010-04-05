require 'uri'

module YammerAPI
  class Base
    YAMMER_API_V1 = 'https://www.yammer.com/api/v1/'
    FORMAT = '.xml'

    class << self
      def url_for(components, parameters = {})
        base = YammerAPI::Base::YAMMER_API_V1
        components.each do |c|
          base += c unless c.nil?
        end
        base += YammerAPI::Base::FORMAT
        
        unless parameters.empty?
          base += '?'
          parameters.each do |k, v|
            base += URI.encode(k.to_s)
            base += '='
            base += URI.encode(v.to_s)
            base += '&'
          end
          base = base[0..(base.length-2)] if base[-1..-1] == '&'
        end
        base
      end

      def get(access_token, components, parameters = {})
        url = url_for(components, parameters)
        access_token.get(url)
      end
    end
  end
end
