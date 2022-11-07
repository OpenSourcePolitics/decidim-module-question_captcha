# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/question_captcha/version"

DECIDIM_VERSION = Decidim::QuestionCaptcha.decidim_compatibility_version

gem "decidim", DECIDIM_VERSION
gem "decidim-question_captcha", path: "."

gem "acts_as_textcaptcha", "~> 4.5.1"
gem "bootsnap", "~> 1.4"
gem "deface"
gem "puma", ">= 5.3.1"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 2.14"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end
