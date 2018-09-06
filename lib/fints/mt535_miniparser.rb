module FinTS
  class MT535Miniparser
    RE_IDENTIFICATION = /^:35B:ISIN\s(.*)\|(.*)\|(.*)$/
    RE_MARKETPRICE = /^:90B::MRKT\/\/ACTU\/([A-Z]{3})(\d*),{1}(\d*)$/
    RE_PRICEDATE = /^:98A::PRIC\/\/(\d*)$/
    RE_PIECES = /^:93B::AGGR\/\/UNIT\/(\d*),(\d*)$/
    RE_TOTALVALUE = /^:19A::HOLD\/\/([A-Z]{3})(\d*),{1}(\d*)$/

    def parse(lines)
      retval = []
      # First: Collapse multiline clauses into one clause
      clauses = collapse_multilines(lines)
      # Second: Scan sequence of clauses for financial instrument
      # sections
      finsegs = grab_financial_instrument_segments(clauses)
      # Third: Extract financial instrument data
      finsegs.each do |finseg|
        isin = name = market_price = price_symbol = price_date = pieces = total_value = nil
        finseg.each do |clause|
          # identification of instrument
          # e.g. ':35B:ISIN LU0635178014|/DE/ETF127|COMS.-MSCI EM.M.T.U.ETF I'
          m = RE_IDENTIFICATION.match(clause)
          if m
            isin = m[1]
            name = m[3]
          end
          # current market price
          # e.g. ':90B::MRKT//ACTU/EUR38,82'
          m = RE_MARKETPRICE.match(clause)
          if m
            price_symbol = m[1]
            market_price = (m[2] + '.' + m[3]).to_f
          end
          # date of market price
          # e.g. ':98A::PRIC//20170428'
          m = RE_PRICEDATE.match(clause)
          price_date = Time.strptime(m[1], '%Y%m%d').date if m
          # number of pieces
          # e.g. ':93B::AGGR//UNIT/16,8211'
          m = RE_PIECES.match(clause)
          pieces = (m[1] + '.' + m[2]).to_s if m
          # total value of holding
          # e.g. ':19A::HOLD//EUR970,17'
          m = RE_TOTALVALUE.match(clause)
          total_value = (m[2] + '.' + m[3]).to_f if m
        end
        # processed all clauses
        retval << {
          ISIN: isin,
          name: name,
          market_value: market_price,
          value_symbol: price_symbol,
          valuation_date: price_date,
          pieces: pieces,
          total_value: total_value
        }
      end
      retval
    end

    def collapse_multilines(lines)
      clauses = []
      prevline = ''
      lines.each do |line|
        if line.start_with?(':')
          clauses << prevline if prevline != ''
          prevline = line
        elsif line.startswith('-')
          # last line
          clauses << prevline
          clauses << line
        else
          prevline += "|#{line}"
        end
      end
      clauses
    end

    def grab_financial_instrument_segments(clauses)
      retval = []
      stack = []
      within_financial_instrument = false
      clauses.each do |clause|
        if clause.start_with?(':16R:FIN')
          # start of financial instrument
          within_financial_instrument = true
        elsif clause.startswith(':16S:FIN')
          # end of financial instrument - move stack over to
          # return value
          retval << stack
          stack = []
          within_financial_instrument = false
        elsif within_financial_instrument
          stack << clause
        end
      end
      retval
    end
  end
end
