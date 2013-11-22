require_dependency 'issue'

module PowerfulWatchersPlugin
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do

        alias_method :visible_without_watchers, :visible?
        alias_method :visible?, :visible_with_watchers

      end
    end

    module ClassMethods

      def visible_condition(user, options={})
        Project.allowed_to_condition(user, :view_issues, options) do |role, user|
          if user.logged?
            case role.issues_visibility
            when 'all'
              nil
            when 'default'
              user_ids = [user.id] + user.groups.map(&:id)
              "(#{table_name}.is_private = #{connection.quoted_false} OR #{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}))"
            when 'own'
              user_ids = [user.id] + user.groups.map(&:id)
              watcher_condition =  "#{table_name}.id IN (select watchable_id from watchers where watchable_type = 'Issue' and user_id = #{user.id})"
              approver_condition = "#{table_name}.id IN (select issue_id from approval_items where user_id = #{user.id})"
              "(#{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}) OR #{watcher_condition} OR #{approver_condition} )"
            else
              '1=0'
            end
          else
            "(#{table_name}.is_private = #{connection.quoted_false})"
          end
        end
      end

    end

    module InstanceMethods

      def visible_with_watchers(usr=nil)
        ( watchers.pluck(:user_id) | approvers.pluck(:user_id) ).include?(usr.try(:id) || User.current.id) || visible_without_watchers(usr)
      end

    end
  end
end
