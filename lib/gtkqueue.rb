require 'monitor'

module Gtk
  GTK_PENDING_BLOCKS = []
  GTK_PENDING_BLOCKS_LOCK = Monitor.new
  GTK_POLL_BLOCKS = []

  def Gtk.queue &block
    if Thread.current == Thread.main
      block.call
    else
      GTK_PENDING_BLOCKS_LOCK.synchronize do
        GTK_PENDING_BLOCKS << block
      end
    end
  end

  def Gtk.poll_block &block
    GTK_PENDING_BLOCKS_LOCK.synchronize do
      GTK_POLL_BLOCKS << block
    end
  end
  

  def Gtk.main_with_queue timeout
    Gtk.timeout_add timeout do
      GTK_PENDING_BLOCKS_LOCK.synchronize do
        for block in GTK_PENDING_BLOCKS
          block.call
        end
        GTK_PENDING_BLOCKS.clear
        for block in GTK_POLL_BLOCKS
          block.call
        end
      end
      true
    end
    Gtk.main
  end
end
