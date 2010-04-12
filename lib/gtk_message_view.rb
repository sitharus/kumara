module Kumara
  class MessageView
    def initialize(parent, message)
      @message = message
      @parent = parent
      create_view
      @parent.pack_end(@main_view, false)
    end

    def create_view
      @main_view = Gtk::VBox.new
      pic_and_message_view = Gtk::HBox.new
      # TODO: pic
      message_view = Gtk::VBox.new
      message_view.pack_start(username_label)
      message_view.pack_start(message)
      
      pic_and_message_view.pack_start(message_view)

      @main_view.pack_start(pic_and_message_view)
      @main_view.pack_start(Gtk::HSeparator.new)
    end

    def username_label
      label = Gtk::Label.new
      label.markup = "<span weight='bold'>#{@message.username}</span>"
      label.set_alignment(0,0)
      label
    end

    def message
      message_label = Gtk::Label.new(@message.plain_body)
      message_label.wrap = true
      message_label.set_alignment(0,0)
      message_label
    end
  end
end
