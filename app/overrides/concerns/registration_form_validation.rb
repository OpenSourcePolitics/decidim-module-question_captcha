# frozen_string_literal: true

module RegistrationFormValidation
  extend ActiveSupport::Concern

  included do
    validate :validate_textcaptcha, if: :perform_textcaptcha?, on: :validate_captcha
  end
end
