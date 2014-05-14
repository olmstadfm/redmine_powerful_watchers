require_dependency 'watcher'

module PowerfulWatchersPlugin
  module WatcherPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      base.class_eval do

        after_create :add_watcher_role
        before_destroy :remove_watcher_role

      end
    end

    module ClassMethods

      def role        
        role_id = Setting[:plugin_redmine_powerful_watchers][:watcher_role_id].to_i
        role = Role.find_by_id(role_id)
        unless role
          Rails.logger.error("  Redmine Powerful Watchers Plugin: there is no watcher_role_id in settings.".red) 
          return nil
        end
        role
      end

    end

    module InstanceMethods

      def add_watcher_role
        if self.watchable_type == 'Issue'

          # project_id = self.watchable.project_id
          # project = Project.find(project_id)
          # user_is_already_member = Member.where(project_id: project_id).pluck(:user_id).include?(self.user_id)
          # member = if user_is_already_member
          #            Member.where(project_id: project_id, user_id: self.user_id).first
          #          else
          #            Member.new(project_id: project_id, user_id: self.user.id)
          #          end
          member = Member.find_or_new(self.watchable.project_id, self.user_id)

          role = Watcher.role
          unless member.roles.include?(role)

            # FIXME 
            # the trick is in avoidance of saving a member
            # (which would trigger the callbacks - add_default_role
            # for example, and we don't need it)
            # look moar in redmine_external_role plugin
            # member_role = member.member_roles.new(role_id: role.id, member: member)
            # member_role.save

            member.add_watcher_role
          end

        end
      end

      def remove_watcher_role
        if self.watchable_type == 'Issue'

          role = Watcher.role

          project_id = self.watchable.project_id
          project = Project.find(project_id)

          other_issues_watched = Watcher.where(watchable_type: 'Issue', watchable_id: project.issues.pluck(:id), user_id: self.user_id).count > 1

          unless other_issues_watched

            Rails.logger.error("begin destroy role".red) 

            member = Member.where(project_id: project_id, user_id: self.user_id).first
            new_roles = member.roles.select{|r| r.id != role.id}
            unless new_roles.empty?
              member.roles = new_roles
              member.save
            else
              member.destroy
            end

            Rails.logger.error("end destroy role".red) 

          end

        end
      end

    end

  end
end
