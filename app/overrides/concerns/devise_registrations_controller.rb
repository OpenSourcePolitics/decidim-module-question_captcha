# frozen_string_literal: true

module DeviseRegistrationsController
  def new
    super
    @form.textcaptcha
  end
end
