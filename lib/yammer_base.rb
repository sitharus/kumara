require 'uri'
require 'nokogiri'

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

      def id_field(sym)
        self.class_eval "def set_id_field(val) instance_variable_set(:@#{sym}, val) end"
        self.class_eval do attr_reader(sym) end
      end
    end

    def initialize(fragment = nil, settings = {})
      if not fragment.nil?
        fragment.children.each do |child|
          next if child.text?
          var_name = child.node_name.gsub(/[^a-zA-Z0-9_]/, '_')
          if self.respond_to? :"load_#{var_name}"
            self.send(:"load_#{var_name}", child)
          else
            # puts "no load_"+var_name
            if var_name == 'id'
              set_id_field(child.content)
            else
              instance_variable_set(('@'+var_name).to_sym, child.content)
            end
          end
        end
      end
      
      settings.each do |k,v|
        instance_variable_set(('@'+k).to_sym, v)
      end

    end
  end
end
