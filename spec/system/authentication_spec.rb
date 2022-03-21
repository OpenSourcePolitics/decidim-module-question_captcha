# frozen_string_literal: true

require "spec_helper"

describe "Authentication", type: :system do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }
  let(:app_questions) do
    {
      en: [{ "question" => "1+1", "answers" => "2" }],
      es: [{ "question" => "2+1", "answers" => "3" }]
    }
  end
  let(:api_questions) { nil }
  let(:api_endpoint) { nil }
  let(:en_api_questions) do
    { "q" => "What is the color of the white horse", "a" => [Digest::MD5.hexdigest("white")] }
  end
  let(:es_api_questions) do
    { "q" => "¿Cuál es el color del caballo gris?", "a" => [Digest::MD5.hexdigest("gris")] }
  end

  let(:cache_store) { :memory_store }

  before do
    allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(cache_store))
    Rails.cache.clear
    allow(Decidim::QuestionCaptcha.config).to receive(:questions).and_return(app_questions)
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  describe "Sign Up" do
    context "when using app provided questions" do
      context "when using email and password" do
        it "creates a new User" do
          sign_up_user(captcha_answer: "2")

          expect(page).to have_content("confirmation link")
        end
      end

      context "when using another language" do
        before do
          within_language_menu do
            click_link "Castellano"
          end
        end

        it "keeps the locale settings" do
          sign_up_user(captcha_answer: "3")

          expect(page).to have_content("Se ha enviado un mensaje con un enlace de confirmación")
          expect(last_user.locale).to eq("es")
        end
      end

      context "when using a language which has no translated question" do
        before do
          within_language_menu do
            click_link "Català"
          end
        end

        it "keeps the locale settings" do
          sign_up_user(captcha_answer: "2")

          expect(page).to have_content("S'ha enviat un missatge amb un enllaç de confirmació")
          expect(last_user.locale).to eq("ca")
        end
      end

      context "when being a robot" do
        it "denies the sign up" do
          sign_up_user(captcha_answer: "2", robot: true)

          expect(page).not_to have_content("confirmation link")
        end
      end

      context "when captcha is wrong" do
        it "denies the sign up" do
          sign_up_user(captcha_answer: "wrong")

          expect(page).not_to have_content("confirmation link")
        end
      end

      context "when using :null_store" do
        let(:cache_store) { :null_store }

        it "doesn't display a captcha field" do
          find(".sign-up-link").click

          expect(page).not_to have_field(:user_textcaptcha_answer)
        end
      end
    end

    context "when using api provided questions" do
      let(:api_endpoint) { "https:://mock-api.org" }

      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(Decidim::RegistrationForm).to receive(:fetch_q_and_a).and_return(api_questions)
        # rubocop:enable RSpec/AnyInstance
        allow(Decidim::QuestionCaptcha.config).to receive(:api_endpoint).and_return(api_endpoint)
      end

      context "when using email and password" do
        let(:api_questions) { en_api_questions }

        it "creates a new User" do
          sign_up_user(captcha_answer: "white")

          expect(page).to have_content("confirmation link")
        end
      end

      context "when using another language" do
        let(:api_questions) { es_api_questions }

        before do
          within_language_menu do
            click_link "Castellano"
          end
        end

        it "keeps the locale settings" do
          sign_up_user(captcha_answer: "gris")

          expect(page).to have_content("Se ha enviado un mensaje con un enlace de confirmación")
          expect(last_user.locale).to eq("es")
        end
      end

      context "when using a language which has no translated question" do
        let(:api_questions) { en_api_questions }

        before do
          within_language_menu do
            click_link "Català"
          end
        end

        it "keeps the locale settings" do
          sign_up_user(captcha_answer: "white")

          expect(page).to have_content("S'ha enviat un missatge amb un enllaç de confirmació")
          expect(last_user.locale).to eq("ca")
        end
      end

      context "when api response returns no question" do
        let(:api_questions) { nil }

        before do
          within_language_menu do
            click_link "Castellano"
          end
        end

        it "falbacks to app questions" do
          sign_up_user(captcha_answer: "3")

          expect(page).to have_content("Se ha enviado un mensaje con un enlace de confirmación")
          expect(last_user.locale).to eq("es")
        end
      end

      context "when being a robot" do
        let(:api_questions) { en_api_questions }

        it "denies the sign up" do
          sign_up_user(captcha_answer: "white", robot: true)

          expect(page).not_to have_content("confirmation link")
        end
      end

      context "when captcha is wrong" do
        let(:api_questions) { en_api_questions }

        it "denies the sign up" do
          sign_up_user(captcha_answer: "wrong")

          expect(page).not_to have_content("confirmation link")
        end
      end

      context "when using :null_store" do
        let(:cache_store) { :null_store }

        it "doesn't display a captcha field" do
          find(".sign-up-link").click

          expect(page).not_to have_field(:user_textcaptcha_answer)
        end
      end
    end
  end

  private

  def sign_up_user(captcha_answer: nil, robot: false)
    find(".sign-up-link").click

    within ".new_user" do
      page.execute_script("$($('.new_user > div > input')[0]).val('Ima robot :D')") if robot
      fill_in :registration_user_email, with: "user@example.org"
      fill_in :registration_user_name, with: "Responsible Citizen"
      fill_in :registration_user_nickname, with: "responsible"
      fill_in :registration_user_password, with: "DfyvHn425mYAy2HL"
      fill_in :registration_user_password_confirmation, with: "DfyvHn425mYAy2HL"
      fill_in :registration_user_textcaptcha_answer, with: captcha_answer
      check :registration_user_tos_agreement
      check :registration_user_newsletter
      find("*[type=submit]").click
    end
  end
end
