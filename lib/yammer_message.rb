module YammerAPI
  class Message < Base
    class << self
      def fetch(access_token, group=nil, id=nil, parameters = {})
        YammerAPI::Base.get(access_token, [group, id], parameters)
      end

      def fetch_latest(access_token)
        doc = Nokogiri::XML(fetch(access_token, 'messages').body)
        messages = []
        doc.xpath("response/messages/message").each do |m|
          messages << Message.new(m)
        end
        messages
      end
    end

    id_field :message_id
    attr_reader :liked_by, :thread_id, :created_at, :message_type, :url, :attachments, :web_url, :client_url
    attr_reader :parsed_body, :plain_body, :system_message, :sender_id, :replied_to_id
    attr_reader :client_type, :sender_type, :group_id

    def initialize(document = nil, settings = {})
      super(document, settings)
    end

    def load_body(body_fragment)
      @parsed_body = body_fragment.xpath('parsed').first.content
      @plain_body = body_fragment.xpath('plain').first.content
    end

  end
end
