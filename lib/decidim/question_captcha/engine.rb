# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module QuestionCaptcha
    # This is the engine that runs on the public interface of question_captcha.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::QuestionCaptcha

      routes do
        # Add engine routes here
        # resources :question_captcha
        # root to: "question_captcha#index"
      end

      initializer "decidim_question_captcha.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_question_captcha.overrides" do
        config.to_prepare do
          ActsAsTextcaptcha::TextcaptchaApi.class_eval do
            prepend(::TextCaptchaApi)
          end

          Decidim::Devise::RegistrationsController.class_eval do
            prepend(::DeviseRegistrationsController)
          end

          Decidim::RegistrationForm.class_eval do
            extend(ActsAsTextcaptcha::Textcaptcha)
            include(Decidim::QuestionCaptcha::HasCaptcha)
            include(::RegistrationFormValidation)
          end

          Decidim::CreateRegistration.class_eval do
            prepend(::CreateRegistration)
          end
        end
      end
    end
  end
end
