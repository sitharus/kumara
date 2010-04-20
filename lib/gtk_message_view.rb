require 'open-uri'

module Kumara
  class MessageView
    def initialize(parent, message)
      @@default_user_image ||= Gdk::Pixbuf.new(Gdk::Pixbuf::COLORSPACE_RGB, 1, 8, 48, 48)


      @message = message
      @parent = parent
      create_view
      @parent.pack_end(@main_view, false)
    end

    def create_view
      @main_view = Gtk::VBox.new
      pic_and_message_view = Gtk::HBox.new(false, 10)
      pic_and_message_view.border_width = 5

      # TODO: pic
      pic_view = Gtk::Image.new(@@default_user_image)
      pic_view.set_alignment(0.5, 0)
      pic_and_message_view.pack_start(pic_view, false, false)
      
      if @message.user.mugshot_url
        url = @message.user.mugshot_url
        key = @message.user.user_id
        if Kumara::ImageCache[key]
          set_image(pic_view, key)
        else
          Thread.new do
            open(url) { |u|
              puts 'Got image'
              Kumara::ImageCache[key] = u.read
              Gtk.queue do
                set_image(pic_view, key)
              end
            }
          end
        end
      end
      
      message_view = Gtk::VBox.new(false, 5)
      message_view.pack_start(username_label)
      message_view.pack_start(message)
      
      pic_and_message_view.pack_start(message_view)

      @main_view.pack_start(pic_and_message_view)
      @main_view.pack_start(info_view)
      @main_view.pack_start(Gtk::HSeparator.new, 5)
    end

    def username_label
      t = "<span weight='bold'>#{@message.username}</span>"
      t += " in #{@message.group.full_name}" if @message.group
      label = Gtk::Label.new
      label.markup = t
      label.set_alignment(0,0)
      label
    end

    def message
      message_label = Gtk::Label.new(@message.plain_body)
      message_label.wrap = true
      message_label.set_alignment(0,0)
      message_label.selectable = true
      message_label
    end

    def info_view
      info_view = Gtk::Label.new
      info_view.markup = "<small>Posted #{@message.created_at.strftime('%Y/%m/%d %H:%M')}</small>"
      info_view.set_alignment(0,0)
      info_view
    end

    def set_image(pic_view, key)
      begin
        image = Gdk::Pixbuf.new(Kumara::ImageCache.file_name(key), 48, 48)
        pic_view.pixbuf = image
      rescue => e
        puts "Unknown image file format for user image #{key}"
      end
    end
  end
end
