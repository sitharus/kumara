module YammerAPI
  class Group < Base
    class << self
      def add(group)
        @groups ||= {}
        @groups[group.group_id] = group
      end

      def [](id)
        @groups[id]
      end
    end

    id_field :group_id
    attr_accessor :mugshot_url, :url, :privacy, :web_url, :full_name, :created_at, :name, :description
  end
end
