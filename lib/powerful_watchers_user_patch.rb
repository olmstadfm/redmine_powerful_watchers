require_dependency 'user'

module PowerfulWatchersPlugin
  module UserPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do

        alias_method :allowed_to_without_watchers, :allowed_to?
        alias_method :allowed_to?, :allowed_to_with_watchers

      end
    end

    module ClassMethods

    end

    module InstanceMethods

      def allowed_to_with_watchers(action, context, options={}, &block)

        action_condition = (action == {controller: 'issues', action: 'show'})

        if context && context.is_a?(Project)
          context_condition = Issue.where( :id => Watcher.where( :watchable_type => 'Issue', :user_id => 479 ).pluck(:watchable_id)).pluck(:project_id).include?(context.id)
        end

        if action_condition && context_condition
          true
        else
          allowed_to_without_watchers(action, context, options, &block)
        end

      end

    end
  end
end
