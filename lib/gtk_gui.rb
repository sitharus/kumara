require 'gtk2'
require 'gconf2'
require File.dirname(File.expand_path(__FILE__)) + '/oauth_config'
require File.dirname(File.expand_path(__FILE__)) + '/yammer_api'
require File.dirname(File.expand_path(__FILE__)) + '/gtk_message_cell'

module Kumara
  class GtkGui
    
    def initialize
      @client = YammerAPI::Client.new(Yammr::OauthConfig::APP_KEY, Yammr::OauthConfig::APP_SECRET)
      @gconf_client = GConf::Client.default
    end
    
    def start
      @main_window = Gtk::Window.new
      @main_window.set_default_size(200, 600)
      @main_window.title = "Kumara"
      @main_window.signal_connect("destroy") do
        Gtk.main_quit
      end

      @main_window.show_all
      if @gconf_client["/apps/yammr/access_token"]
        @client.set_credentials(@gconf_client["/apps/yammr/access_token"], @gconf_client["/apps/yammr/access_token_secret"])
        setup_main_window
      else
        oauth_prompt
      end
      Gtk.main
    end

    def setup_main_window
      @main_vbox = Gtk::VBox.new
      add_menu_bar
      add_message_list
      @main_window.add(@main_vbox)
      @main_window.show_all

      fetch_messages
      @message_view.show_all
    end

    def add_menu_bar
      menubar = Gtk::MenuBar.new
      accel_group = Gtk::AccelGroup.new

      edit = Gtk::MenuItem.new("Edit")
      editmenu = Gtk::Menu.new
      edit.submenu = editmenu
      
      editmenu.append(Gtk::ImageMenuItem.new(Gtk::Stock::CUT, accel_group))
      editmenu.append(Gtk::ImageMenuItem.new(Gtk::Stock::COPY, accel_group))
      editmenu.append(Gtk::ImageMenuItem.new(Gtk::Stock::PASTE, accel_group))
      editmenu.append(Gtk::MenuItem.new)

      preferences_item = Gtk::MenuItem.new("Preferences")
      preferences_item.signal_connect("activate") do |m|
        show_preferences
      end
      
      editmenu.append(preferences_item)
      
      menubar.append(edit)
      @main_vbox.pack_start(menubar, false)
    end

    def add_message_list


    end

    # Add a single button to the window to go to oauth login
    # TODO: Design
    def oauth_prompt
      oauth_vbox = Gtk::VBox.new
      inner_vbox = Gtk::VBox.new
      oauth_vbox.pack_start(inner_vbox, false)
      inner_vbox.pack_start(Gtk::Label.new("Login with OAuth"))
      oauth_button = Gtk::Button.new("Login")
      inner_vbox.pack_start(oauth_button, false)
      @main_window.add(oauth_vbox)
      @main_window.show_all

      oauth_button.signal_connect("clicked") do |w|
        destination_url = @client.start_oauth
        # Ruby-gnome2 doesn't have gtk_open_uri yet. Annoying.
        # TODO: Better fix for obvious shell injection attack.
        `gnome-open '#{destination_url.gsub("'","")}'`
        @main_window.remove(oauth_vbox)
        oauth_verification_prompt
        oauth_vbox.destroy
      end
    end

    # Display the prompt to enter the OAuth verification code
    # TODO: Make prettier
    def oauth_verification_prompt
      verification_window = Gtk::Dialog.new("Verification Code", @main_window, Gtk::Dialog::MODAL, ["Connect", Gtk::Dialog::RESPONSE_ACCEPT])

      code_hbox = Gtk::HBox.new
      code_hbox.pack_start(Gtk::Label.new("Verification Code"))
      code_entry = Gtk::Entry.new
      code_hbox.pack_start(code_entry)

      verification_window.vbox.pack_start(code_hbox)
      begin
        verification_window.show_all
        verification_window.run do |response|
          case response
          when Gtk::Dialog::RESPONSE_ACCEPT
            @client.finish_oauth(code_entry.text)
            @gconf_client["/apps/yammr/access_token"] = @client.access_token
            @gconf_client["/apps/yammr/access_token_secret"] = @client.access_token_secret
            setup_main_window
          end
        end
      rescue Exception => e
        failure = Gtk::Dialog.new("Verification Failed", @main_window, Gtk::Dialog::MODAL, [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])
        failure.vbox.pack_start(Gtk::Label.new("OAuth verification failed, check the code and try again"))
        puts e
        puts e.backtrace
        retry
      end
      verification_window.destroy
    end

    def fetch_messages
      @client.fetch_messages.each do |message|
      end
    end

  end
end
