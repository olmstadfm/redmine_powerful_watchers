module PowerfulWatchersPlugin
  module ProjectPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :users_by_role, :watchers
      end
    end

    module ClassMethods

    end

    module InstanceMethods

      def users_by_role_with_watchers
        hash = users_by_role_without_watchers
        hash.delete(Role.find_by_id(Setting[:plugin_redmine_powerful_watchers][:watcher_role_id].to_i))
        hash
      end

    end
  end
end
