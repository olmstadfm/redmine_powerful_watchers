require_dependency 'issue'

module PowerfulWatchersPlugin
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do

        alias_method :visible_without_watchers, :visible?
        alias_method :visible?, :visible_with_watchers


#        alias_method_chain :visible?, :watchers

      end
    end

    module ClassMethods

    end

    module InstanceMethods

      def visible_with_watchers(usr=nil)
        watchers.pluck(:user_id).include?(User.current.id) || visible_without_watchers(usr)
      end

    end
  end
end
