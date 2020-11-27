# frozen_string_literal: true

require "spec_helper"

describe "Authentication", type: :system do
  let(:organization) { create(:organization) }
  let(:last_user) { Decidim::User.last }
  let(:questions) do
    {
      en: [{ "question" => "1+1", "answers" => "2" }],
      es: [{ "question" => "2+1", "answers" => "3" }]
    }
  end

  before do
    allow(Decidim::QuestionCaptcha.config).to receive(:questions).and_return(questions)
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  describe "Sign Up" do
    context "when using email and password" do
      it "creates a new User" do
        find(".sign-up-link").click

        within ".new_user" do
          fill_fields(captcha_answer: "2")
        end

        expect(page).to have_content("You have signed up successfully")
      end
    end

    context "when using another language" do
      before do
        within_language_menu do
          click_link "Castellano"
        end
      end

      it "keeps the locale settings" do
        find(".sign-up-link").click

        within ".new_user" do
          fill_fields(captcha_answer: "3")
        end

        expect(page).to have_content("¡Bienvenida! Te has registrado con éxito.")
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
        find(".sign-up-link").click

        within ".new_user" do
          fill_fields(captcha_answer: "2")
        end

        expect(page).to have_content("Benvinguda! Has iniciat la sessió amb èxit.")
        expect(last_user.locale).to eq("ca")
      end
    end

    context "when being a robot" do
      it "denies the sign up" do
        find(".sign-up-link").click

        within ".new_user" do
          fill_fields(captcha_answer: "2", robot: true)
        end

        expect(page).not_to have_content("You have signed up successfully")
      end
    end

    context "when captcha is wrong" do
      it "denies the sign up" do
        find(".sign-up-link").click

        within ".new_user" do
          fill_fields(captcha_answer: "wrong")
        end

        expect(page).not_to have_content("You have signed up successfully")
      end
    end

    context "when using :null_store" do
      before do
        allow(Rails.application.config).to receive(:cache_store).with(:null_store)
      end

      it "doesn't display a captcha field" do
        find(".sign-up-link").click

        expect(page).not_to have_field(:user_textcaptcha_answer)
      end
    end
  end

  private

  def fill_fields(captcha_answer: nil, robot: false)
    if robot
      page.execute_script("$($('.new_user > div > input')[0]).val('Ima robot :D')")
    end
    fill_in :user_email, with: "user@example.org"
    fill_in :user_name, with: "Responsible Citizen"
    fill_in :user_nickname, with: "responsible"
    fill_in :user_password, with: "DfyvHn425mYAy2HL"
    fill_in :user_password_confirmation, with: "DfyvHn425mYAy2HL"
    fill_in :user_textcaptcha_answer, with: captcha_answer
    check :user_tos_agreement
    check :user_newsletter
    find("*[type=submit]").click
  end
end
