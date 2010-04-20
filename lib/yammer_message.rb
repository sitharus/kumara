module YammerAPI
  class Message < Base
    class << self
      def fetch(access_token, group=nil, id=nil, parameters = {})
        YammerAPI::Base.get(access_token, [group, id], parameters)
      end

      def fetch_latest(access_token)
        doc = Nokogiri::XML(fetch(access_token, 'messages').body)

        doc.xpath("response/references/reference").each do |r|
          case r.xpath("type").first.content
          when 'user'
            puts 'user'
            User.add(User.new(r))
          when 'group'
            puts 'group'
            Group.add(Group.new(r))
          end
        end

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

    attr_reader :user

    def initialize(document = nil, settings = {})
      super(document, settings)

      @user = User[@sender_id]
    end

    def load_body(body_fragment)
      @parsed_body = body_fragment.xpath('parsed').first.content
      @plain_body = body_fragment.xpath('plain').first.content
    end
    
    def load_created_at(f)
      @created_at = DateTime.parse(f.content)
    end

    def username
      @user.full_name
    end

    def group
      @group_id and Group[@group_id]
    end

  end
end
