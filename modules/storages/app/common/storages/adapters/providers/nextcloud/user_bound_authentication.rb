# frozen_string_literal: true

#-- copyright
#++

module Storages
  module Adapters
    module Providers
      module Nextcloud
        class UserBoundAuthentication
          def self.call(user, storage)
            new(user, storage).call
          end

          def initialize(user, storage)
            @user = user
            @storage = storage
          end

          def call
            key = if @storage.authenticate_via_idp? && user_provided_by_oidc?
                    :sso_user_token
                  else
                    :oauth_user_token
                  end

            Input::Strategy.build(key:, user: @user)
          end

          private

          def user_provided_by_oidc?
            @user.authentication_provider.is_a?(OpenIDConnect::Provider)
          end
        end
      end
    end
  end
end
