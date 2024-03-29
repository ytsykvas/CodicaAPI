# frozen_string_literal: true

class ApplicationController < ActionController::API
  include SimpleTokenAuthentication::ActsAsTokenAuthenticationHandler

  acts_as_token_authentication_handler_for User
end
