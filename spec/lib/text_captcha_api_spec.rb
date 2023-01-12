# frozen_string_literal: true

require "spec_helper"

module ActsAsTextcaptcha
  describe TextcaptchaApi do
    subject { described_class.new }

    context "when the API is returning a success code" do
      before do
        stub_request(:get, "https://textcaptcha.com:80/.json")
          .with(
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "Host" => "textcaptcha.com",
              "User-Agent" => "Ruby"
            }
          )
          .to_return(status: 200, body: "Forcing https", headers: {})
      end

      describe "#get" do
        it "returns a hash with the questions" do
          expect(subject.get).to eq("Forcing https")
        end
      end
    end

    context "when the API is returing an error code" do
      before do
        stub_request(:get, "https://textcaptcha.com:80/.json")
          .with(
            headers: {
              "Accept" => "*/*",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "Host" => "textcaptcha.com",
              "User-Agent" => "Ruby"
            }
          )
          .to_return(status: 300, body: "Error", headers: {})
      end

      describe "#get" do
        it "returns nothing" do
          expect(subject.get).to be_nil
        end
      end
    end
  end
end
