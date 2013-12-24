Redmine::Plugin.register :redmine_powerful_watchers do
  name 'Redmine Powerful Watchers plugin'
  author 'a'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  settings :partial => 'powerful_watchers/settings'

end

Rails.configuration.to_prepare do
  [:issue, :watcher, :project].each do |cl|
    require "powerful_watchers_#{cl}_patch"
  end

  [
   [Issue,   PowerfulWatchersPlugin::IssuePatch],
   [Watcher, PowerfulWatchersPlugin::WatcherPatch],
   [Project, PowerfulWatchersPlugin::ProjectPatch]
  ].each do |cl, patch|
    cl.send(:include, patch) unless cl.included_modules.include? patch
  end
end
