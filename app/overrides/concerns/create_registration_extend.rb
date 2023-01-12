# frozen_string_literal: true

module CreateRegistrationExtend
  def call
    if form.invalid?(:validate_captcha)
      user = Decidim::User.has_pending_invitations?(form.current_organization.id, form.email)
      user.invite!(user.invited_by) if user
      return broadcast(:invalid)
    end

    create_user

    broadcast(:ok, @user)
  rescue ActiveRecord::RecordInvalid
    broadcast(:invalid)
  end
end
