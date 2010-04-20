module YammerAPI
  class User < Base
    class << self
      def add(user)
        @users ||= {}
        @users[user.user_id] = user
      end

      def [](id)
        @users[id]
      end
    end

    id_field :user_id
    attr_reader :state, :mugshot_url, :url, :full_name, :web_url, :name, :job_title
    attr_reader :following_count, :follower_count, :update_count

    def load_stats(stats)
      @following_count = stats.xpath('following').first.content.to_i
      @follower_count = stats.xpath('followers').first.content.to_i
      @update_count = stats.xpath('updates').first.content.to_i
    end
  end
end
