# frozen_string_literal: true

require "spec_helper"

module Decidim
  module QuestionCaptcha
    describe HasCaptcha do
      subject do
        class DummyClass < Decidim::Form
          extend(ActsAsTextcaptcha::Textcaptcha)
          include(Decidim::QuestionCaptcha::HasCaptcha)
        end
      end

      let(:subject_instance) { subject.new }

      let(:app_questions) do
        {
          en: [{ "question" => "99+1", "answers" => "100" }]
        }
      end

      let(:current_locale) { :en }
      let(:default_locale) { :en }

      before do
        allow(I18n).to receive(:locale).and_return(current_locale)
        allow(I18n).to receive(:default_locale).and_return(default_locale)
        allow(Decidim::QuestionCaptcha.config).to receive(:questions).and_return(app_questions)
      end

      describe ".captcha_questions" do
        it "returns the questions from the config" do
          expect(subject.captcha_questions).to eq(app_questions)
        end

        context "when locale is not present" do
          let(:current_locale) { :es }

          it "returns the questions from the default locale" do
            expect(subject.captcha_questions).to eq(app_questions)
          end
        end

        context "when locale is not present and default locale is not present" do
          let(:current_locale) { :es }
          let(:default_locale) { :ca }

          it "returns the questions from the fallback locale" do
            expect(subject.captcha_questions).to eq(app_questions)
          end
        end
      end

      describe "#perform_textcaptcha?" do
        context "when cache is enabled" do
          let(:cache_store) { :memory_store }

          before do
            allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache.lookup_store(cache_store))
            Rails.cache.clear
          end

          it "returns the value from the config" do
            expect(subject_instance.perform_textcaptcha?).to eq(Decidim::QuestionCaptcha.config.perform_textcaptcha)
          end
        end
      end

      describe "#current_locale" do
        it "returns the current locale" do
          expect(subject_instance.current_locale).to eq(I18n.locale)
        end
      end

      describe "#default_locale" do
        it "returns the default locale" do
          expect(subject_instance.default_locale).to eq(I18n.default_locale)
        end
      end

      describe "#fallback_locale" do
        it "returns the fallback locale" do
          expect(subject_instance.fallback_locale).to eq(app_questions.keys.first)
        end
      end

      describe "#textcaptcha" do
        before do
          allow(subject_instance).to receive(:perform_textcaptcha?).and_return(true)
        end

        it "setup a question" do
          subject_instance.textcaptcha

          expect(subject_instance.textcaptcha_question).to eq("99+1")
        end
      end
    end
  end
end
