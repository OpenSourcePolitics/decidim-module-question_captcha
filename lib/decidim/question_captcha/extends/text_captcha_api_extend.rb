# frozen_string_literal: true

module TextCaptchaApiExtend
  def get
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.get(uri)
    if response.code == "200"
      response.body
    else
      handle_error ResponseError.new(uri, "status: #{response.code}")
    end
  rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
         Errno::EHOSTUNREACH, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
         Net::ProtocolError => e
    handle_error ResponseError.new(uri, e)
  end
end

ActsAsTextcaptcha::TextcaptchaApi.class_eval do
  prepend(TextCaptchaApiExtend)
end
