module FinTS
  class Helper
    def self.fints_escape(content)
      content.gsub('?', '??').gsub('+', '?+').gsub(':', '?:').gsub("'", "?'")
    end

    def self.fints_unescape(content)
      content.gsub('??', '?').gsub("?'", "'").gsub('?+', '+').gsub('?:', ':')
    end

    def self.mt940_to_array(data)
      processed_data = data.gsub('@@', "\n").gsub('-0000', '+0000')
      mt940 = Cmxl.parse(processed_data)
      mt940.flat_map(&:transactions)
    end
  end
end
