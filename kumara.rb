$: << File.dirname(File.expand_path(__FILE__))

require 'lib/client'
require 'lib/gtk_gui'

gui = Kumara::GtkGui.new
gui.start
