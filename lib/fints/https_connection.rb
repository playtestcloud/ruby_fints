module FinTS
  class HTTPSConnection
    def initialize(url)
      @url = url
    end

    def send_msg(msg)
      message_string = msg.to_s.encode('iso-8859-1')
      FinTS::Client.logger.debug("<< #{message_string}")
      data = Base64.encode64(message_string)
      response = HTTParty.post(@url, body: data, headers: {'Content-Type' => 'text/plain', })
      if response.code < 200 || response.code > 299
        raise ConnectionError, "Bad status code #{response.code}"
      end
      res = Base64.decode64(response.body).force_encoding('iso-8859-1').encode('utf-8')
      FinTS::Client.logger.debug(">> #{res}")
      res
    end
  end
end
