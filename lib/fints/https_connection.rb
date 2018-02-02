module FinTS
  class HTTPSConnection
    def initialize(url)
      @url = URI(url)
    end

    def send_msg(msg)
      message_string = msg.to_s.encode('iso-8859-1')
      FinTS::Client.logger.debug("<< #{message_string}")
      data = Base64.encode64(message_string)

      response = Net::HTTP.start(@url.host, @url.port, use_ssl: @url.scheme == 'https') do |http|
        http.post(@url.path, data, {'Content-Type' => 'text/plain'})
      end
      code = response.code.to_i
      if code < 200 || code > 299
        raise ConnectionError, "Bad status code #{code}"
      end
      res = Base64.decode64(response.body).force_encoding('iso-8859-1').encode('utf-8')
      FinTS::Client.logger.debug(">> #{res}")
      res
    end
  end
end
