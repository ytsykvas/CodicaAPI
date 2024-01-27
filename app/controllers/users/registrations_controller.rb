# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    # POST /resource
    def create
      super do |user|
        if user.persisted?
          render json: user
        else
          clean_up_passwords user
          set_minimum_password_length
          respond_with user
        end
        return
      end
    end
  end
end
