# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/question_captcha/version"

Gem::Specification.new do |s|
  s.version = Decidim::QuestionCaptcha.version
  s.authors = ["Armand Fardeau"]
  s.email = ["fardeauarmand@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-question_captcha"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-question_captcha"
  s.summary = "A decidim question_captcha module"
  s.description = "Question based captcha for Decidim."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "acts_as_textcaptcha", "~> 4.5.1"
  s.add_dependency "decidim-core", Decidim::QuestionCaptcha.version
end
