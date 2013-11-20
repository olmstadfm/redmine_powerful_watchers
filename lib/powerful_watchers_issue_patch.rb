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

# watchers condition
# select id from issues where issues.id in (select watchable_id from watchers where watchable_type = 'Issue' AND user_id = 277);

# approver_condition
# select id from issues where issues.id in (select issue_id from approval_items where user_id = 479);

# watchers_condition = "#{table_name}.id in (select watchable_id from watchers where watchable_type = 'Issue' AND user_id = #{user.id});"
# approver_condition = "#{table_name}.id in (select issue_id from approval_items where user_id = #{user.id});"
