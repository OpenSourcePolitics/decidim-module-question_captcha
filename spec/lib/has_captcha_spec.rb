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

      before do
        allow(Decidim::QuestionCaptcha.config).to receive(:questions).and_return(app_questions)
      end

      describe ".captcha_questions" do
        it "returns the questions from the config" do
          expect(subject.captcha_questions).to eq(app_questions)
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
