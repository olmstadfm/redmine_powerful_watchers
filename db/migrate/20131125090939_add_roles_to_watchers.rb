class AddRolesToWatchers < ActiveRecord::Migration

  # to make this migration work you should first create 'Watcher'
  # role, and connect it to powerful_watchers plugin in it's settings
  
  def self.up
    Watcher.all.each{|w| w.add_watcher_role rescue nil}
  end

  def self.down
    Watcher.all.each{|w| w.remove_watcher_role rescue nil}
  end

end

