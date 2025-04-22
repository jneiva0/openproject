# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module TimeEntries
  class BaseContract < ::ModelContract
    include AssignableValuesContract
    include AssignableCustomFieldValues

    delegate :work_package,
             :project,
             :available_custom_fields,
             :new_record?,
             to: :model

    def self.model
      TimeEntry
    end

    validate :validate_hours_are_in_range
    validate :validate_project_is_set
    validate :validate_entity
    validate :validate_user

    validates :spent_on,
              date: { before_or_equal_to: Proc.new { Date.new(9999, 12, 31) },
                      allow_blank: true },
              unless: Proc.new { spent_on.blank? }

    attribute :project_id
    attribute :work_package_id
    attribute :activity_id do
      validate_activity_active
    end
    attribute :ongoing do
      validate_self_timer
    end
    attribute :hours
    attribute :comments
    attribute_alias :comments, :comment

    attribute :spent_on
    attribute :tyear
    attribute :tmonth
    attribute :tweek
    attribute :user_id,
              permission: :log_time

    attribute :start_time # TODO: Add validation with global setting

    def assignable_activities
      if model.project
        TimeEntryActivity.active_in_project(model.project)
      else
        TimeEntryActivity.none
      end
    end

    # Necessary for custom fields of type version.
    def assignable_versions(only_open: true)
      work_package.try(:assignable_versions, only_open:) || project.try(:assignable_versions, only_open:) || []
    end

    private

    def validate_entity
      return unless model.entity || model.entity_changed?

      if model.entity.is_a?(WorkPackage)
        if work_package_invisible? || work_package_not_in_project?
          errors.add :entity, :invalid
        end
      elsif model.entity.is_a?(TimeEntry)
        # TODO: Add validation for time entry
        true
      end
    end

    def validate_user
      return unless model.user || model.user_id_changed?
      return if model.user == model.logged_by

      if user_invisible?
        errors.add :user_id, :invalid
      end
    end

    def validate_hours_are_in_range
      errors.add :hours, :invalid if model.hours&.negative?
    end

    def validate_project_is_set
      errors.add :project_id, :invalid if model.project.nil?
    end

    def validate_activity_active
      errors.add :activity_id, :inclusion if model.activity_id && !assignable_activities.exists?(model.activity_id)
    end

    def work_package_invisible?
      model.entity.nil? || !model.entity.visible?(user)
    end

    def work_package_not_in_project?
      model.entity && model.project != model.entity.project
    end

    def user_invisible?
      model.user.nil? || !model.user.visible?
    end

    def validate_self_timer
      errors.add :ongoing, :not_current_user if model.ongoing? && model.user != user
    end
  end
end
