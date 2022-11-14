# frozen_string_literal: true

require "decidim/question_captcha/admin"
require "decidim/question_captcha/engine"
require "decidim/question_captcha/admin_engine"

module Decidim
  # This namespace holds the logic of the `QuestionCaptcha` component. This component
  # allows users to create question_captcha in a participatory space.
  module QuestionCaptcha
    autoload :HasCaptcha, "decidim/question_captcha/has_captcha"

    include ActiveSupport::Configurable

    config_accessor :questions do
      if Rails.env.test?
        {
          en: [
            { "question" => "99+1", "answers" => "100" }
          ],
          es: [
            { "question" => "49+1", "answers" => "50" }
          ],
          ca: [
            { "question" => "19+1", "answers" => "20" }
          ]
        }
      else
        {
          en: [
            { "question" => "1+1", "answers" => "2,two" },
            { "question" => "The green hat is what color?", "answers" => "green" }
          ],
          es: [
            { "question" => "1+2", "answers" => "3,tres" },
            { "question" => "El sombrero verde es de qué color?", "answers" => "verde" }
          ],
          ca: [
            { "question" => "2+2", "answers" => "4,quatre" },
            { "question" => "El barret verd és de quin color?", "answers" => "verd" }
          ]
        }
      end
    end

    config_accessor :perform_textcaptcha do
      true
    end

    config_accessor :expiration_time do
      10
    end

    config_accessor :raise_error do
      false
    end

    config_accessor :api_endpoint do
      "https://testm1obgqmc-decidimcaptchaapi.functions.fnc.fr-par.scw.cloud/"
    end
  end
end
