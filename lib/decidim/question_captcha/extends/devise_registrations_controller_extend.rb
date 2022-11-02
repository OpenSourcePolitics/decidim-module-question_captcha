# frozen_string_literal: true

module DeviseRegistrationControllerExtend
  def new
    super
    @form.textcaptcha
  end
end

Decidim::Devise::RegistrationsController.class_eval do
  prepend(DeviseRegistrationControllerExtend)
end
