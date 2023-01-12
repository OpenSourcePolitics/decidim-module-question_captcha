# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Comments
    describe CreateRegistration do
      describe "call" do
        let(:organization) { create(:organization) }

        let(:name) { "Username" }
        let(:nickname) { "nickname" }
        let(:email) { "user@example.org" }
        let(:password) { "Y1fERVzL2F" }
        let(:password_confirmation) { password }
        let(:tos_agreement) { "1" }
        let(:newsletter) { "1" }
        let(:current_locale) { "es" }
        let(:textcaptcha_answer) { 100 }

        let(:form_params) do
          {
            "user" => {
              "name" => name,
              "nickname" => nickname,
              "email" => email,
              "password" => password,
              "password_confirmation" => password_confirmation,
              "tos_agreement" => tos_agreement,
              "newsletter_at" => newsletter,
              "textcaptcha_answer" => textcaptcha_answer
            }
          }
        end
        let(:form) do
          RegistrationForm.from_params(
            form_params,
            current_locale: current_locale
          ).with_context(
            current_organization: organization
          )
        end
        let(:command) { described_class.new(form) }
        let(:cache_store) { :memory_store }

        before do
          allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(cache_store))
          Rails.cache.clear
          form.textcaptcha
        end

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a user" do
            expect do
              command.call
            end.not_to change(User, :count)
          end

          context "when the user was already invited" do
            let(:user) { build(:user, email: email, organization: organization) }

            before do
              user.invite!
              clear_enqueued_jobs
              RSpec::Matchers.define_negated_matcher :not_change, :change
            end

            it "receives the invitation email again" do
              expect do
                command.call
                user.reload
              end.to not_change(User, :count)
                .and broadcast(:invalid)
                .and change(user.reload, :invitation_token)
              expect(ActionMailer::MailDeliveryJob).to have_been_enqueued.on_queue("mailers")
            end
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new user" do
            expect(User).to receive(:create!).with(
              name: form.name,
              nickname: form.nickname,
              email: form.email,
              password: form.password,
              password_confirmation: form.password_confirmation,
              tos_agreement: form.tos_agreement,
              newsletter_notifications_at: form.newsletter_at,
              organization: organization,
              accepted_tos_version: organization.tos_version,
              locale: form.current_locale
            ).and_call_original

            expect { command.call }.to change(User, :count).by(1)
          end

          describe "when user keeps the newsletter unchecked" do
            let(:newsletter) { "0" }

            it "creates a user with no newsletter notifications" do
              expect do
                command.call
                expect(User.last.newsletter_notifications_at).to be_nil
              end.to change(User, :count).by(1)
            end
          end
        end
      end
    end
  end
end
