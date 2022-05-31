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
      {
        en: [
          { "question" => "1+1", "answers" => "2,two" },
          { "question" => "The green hat is what color?", "answers" => "Green,green" },
          { "question" => "What color is the black cat?", "answers" => "Black,black" },
          { "question" => "What is the second color in the list: language, gray, orange?", "answers" => "Gray,gray" },
          { "question" => "What is the color of the white horse of Henry IV?", "answers" => "White,white" },
          { "question" => "Pink, green and elbow: how many colors in the list?", "answers" => "Two,two,2" }
        ],
        es: [
          { "question" => "1+2", "answers" => "3,tres" },
          { "question" => "El sombrero verde es de qué color?", "answers" => "Verde,verde" },
          { "question" => "¿De qué color es el gato negro?", "answers" => "Negro,negro" },
          { "question" => "¿Cuál es el segundo color de la lista: idioma, gris, naranja?", "answers" => "Gris,gris" },
          { "question" => "¿De qué color es el caballo blanco de Enrique IV?", "answers" => "Blanco,blanco" },
          { "question" => "Rosa, verde y codo: ¿cuántos colores en la lista?", "answers" => "Dos,dos,2" }
        ],
        ca: [
          { "question" => "2+2", "answers" => "4,quatre" },
          { "question" => "El barret verd és de quin color?", "answers" => "Verd,verd" },
          { "question" => "De quin color és el gat negre?", "answers" => "Negre,negre" },
          { "question" => "Quin és el segon color de la llista: idioma, gris, taronja?", "answers" => "Gris,gris" },
          { "question" => "Quin és el nombre més gran entre els números següents: 18, cinc, quaranta, cent?", "answers" => "Cent,cent,100" },
          { "question" => "Rosa, verd i colze: quants colors de la llista?", "answers" => "Dos,dos,2" }
        ],
        fr: [
          { "question" => "Quelle est la capitale de la France ?", "answers" => "Paris,paris" },
          { "question" => "De quelle couleur est le chat noir ?", "answers" => "Noir,noir" },
          { "question" => "Quelle est la seconde couleur de la liste : langue, gris, orange ?", "answers" => "Gris,gris" },
          { "question" => "Combien font 15 moins un ?", "answers" => "Quatorze,quatorze,14" },
          { "question" => "Rose, vert et coude : combien de couleurs dans la liste ?", "answers" => "Deux,deux,2" }
        ]
      }
    end

    config_accessor :perform_textcaptcha do
      true
    end

    config_accessor :expiration_time do
      25
    end

    config_accessor :raise_error do
      false
    end

    config_accessor :api_endpoint do
      nil
    end
  end
end
