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

# Decorates a form object to provide a more convenient interface for
# rendering attribute help texts.
#
# It automatically sets the label property.
module AttributeHelpTexts
  class FormDecorator
    include FormHelper

    attr_reader :form

    # Initializes a new AttributeHelpTexts::FormDecorator
    #
    # @param form [Object] The form object to be decorated
    def initialize(form)
      @form = form
    end

    def method_missing(method, ...)
      form.send(method, ...)
    end

    def respond_to_missing?(method, include_private = false)
      form.respond_to?(method, include_private)
    end

    # Creates a text field input for a setting.
    #
    #
    # @param name [Symbol] The name of the setting
    # @param options [Hash] Additional options for the text field
    # @return [Object] The text field input
    def text_field(name:, **options)
      # model_name = options[:builder]
      options.reverse_merge!(
        label: "#{form}"
      )
      form.text_field(name:, **options)
    end
  end
end
