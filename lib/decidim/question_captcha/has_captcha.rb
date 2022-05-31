# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module QuestionCaptcha
    module HasCaptcha
      extend ActiveSupport::Concern

      class_methods do
        def captcha_questions
          Decidim::QuestionCaptcha.config.questions
        end
      end

      included do
        attribute :textcaptcha_answer, String

        acts_as_textcaptcha api_endpoint: Decidim::QuestionCaptcha.config.api_endpoint,
                            raise_errors: Decidim::QuestionCaptcha.config.raise_error,
                            cache_expiry_minutes: Decidim::QuestionCaptcha.config.expiration_time,
                            questions: captcha_questions

        def perform_textcaptcha?
          return unless cache_enabled?

          Decidim::QuestionCaptcha.config.perform_textcaptcha
        end

        def current_locale
          I18n.locale
        end

        def default_locale
          I18n.default_locale
        end

        private

        def cache_enabled?
          Rails.cache.class != ActiveSupport::Cache::NullStore
        end

        def questions
          return if textcaptcha_config[:questions].blank?

          textcaptcha_config[:questions][current_locale] || textcaptcha_config[:questions][default_locale]
        end

        def fetch_q_and_a
          return unless should_fetch?

          ActsAsTextcaptcha::TextcaptchaApi.new(
            api_key: textcaptcha_config[:api_key],
            api_endpoint: api_endpoint(current_locale),
            raise_errors: textcaptcha_config[:raise_errors]
          ).fetch
        end

        def assign_textcaptcha(q_and_a)
          super

          assign_textcaptcha(config_q_and_a) if textcaptcha_question.nil? || textcaptcha_key.nil?
        end

        def api_endpoint(locale)
          "#{textcaptcha_config[:api_endpoint]}?locale=#{locale}"
        end

        def config_q_and_a
          return unless questions

          random_question = questions[rand(questions.size)].symbolize_keys!
          answers = (random_question[:answers] || "").split(",").map! { |answer| safe_md5(answer) }

          { "q" => random_question[:question], "a" => answers } if random_question && answers.present?
        end

        def textcaptcha_config
          Decidim::QuestionCaptcha.config
        end

        def add_textcaptcha_error(too_slow: false)
          if too_slow
            errors.add(:textcaptcha_answer, :expired, message: I18n.t(".expired", scope: "activerecord.errors.models.registration.attributes.textcaptcha_answer"))
          else
            errors.add(:textcaptcha_answer, :incorrect, message: I18n.t(".incorrect", scope: "activerecord.errors.models.registration.attributes.textcaptcha_answer"))
          end
        end
      end
    end
  end
end
