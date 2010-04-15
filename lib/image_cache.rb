module Kumara
  class ImageCache
    class << self
      CACHE_DIR = File.expand_path('~/.kumara_cache')

      def sanitise(key)
        key.gsub(/\.\./, '')
      end

      def file_name(key)
        File.join(CACHE_DIR, sanitise(key))
      end

      def add(image, key)
        if not File.exists(CACHE_DIR)
          File.mkdir(CACHE_DIR)
        end

        File.open(file_name(key)) do |f|
          f << image
        end
      end

      def fetch(key)
        if File.exists(file_name(key))
          File.open(file_name(key)) do |f|
            return f.read
          end
        end
      end

      def [](key)
        fetch(key)
      end

      def []=(key, image)
        add(image, key)
      end
    end
  end
end
