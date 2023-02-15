# frozen_string_literal: true

module DeviseRegistrationsController
  def new
    super
    @form.textcaptcha
  end

  def render(*args)
    @form.textcaptcha if request.parameters[:action] == "create"
    super
  end
end
