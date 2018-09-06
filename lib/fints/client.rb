module FinTS
  class Client
    class << self
      attr_writer :logger

      def logger
        @logger ||= Logger.new($stdout).tap do |log|
          log.progname = name
        end
      end
    end

    def initialize
      @accounts = []
    end

    def get_sepa_accounts
      dialog = new_dialog
      dialog.sync
      dialog.init

      msg_spa = new_message(dialog, [Segment::HKSPA.new(3, nil, nil, nil)])
      FinTS::Client.logger.debug("Sending HKSPA: #{msg_spa}")
      resp = dialog.send_msg(msg_spa)
      FinTS::Client.logger.debug("Got HKSPA response: #{resp}")
      dialog.send_end

      accounts = resp.find_segment('HISPA')
      raise SegmentNotFoundError, 'Could not find HISPA segment' if accounts.nil?
      accountlist = accounts.split('+').drop(1)
      @accounts = accountlist.map do |acc|
        arr = acc.split(':')
        {
          iban: arr[1],
          bic: arr[2],
          accountnumber: arr[3],
          subaccount: arr[4],
          blz: arr[6]
        }
      end
    end

    def get_balance(account)
      FinTS::Client.logger.info('Start fetching balance')

      dialog = new_dialog
      dialog.sync
      dialog.init

      msg = create_balance_message(dialog, account)
      FinTS::Client.logger.debug("Send message: #{msg}")
      resp = dialog.send_msg(msg)
      dialog.send_end

      # find segment and split up to balance part
      seg = resp.find_segment('HISAL')
      arr = Helper.split_for_data_elements(Helper.split_for_data_groups(seg)[4])

      amount = arr[1].sub(',', '.').to_f
      # 'C' for credit, 'D' for debit
      amount *= -1 if arr[0] == 'D'

      balance = {
        amount: amount,
        currency: arr[2],
        date: Date.parse(arr[3])
      }

      FinTS::Client.logger.debug("Balance: #{balance}")
      balance
    end

    def create_balance_message(dialog, account)
      hversion = dialog.hksalversion
      acc = format_account_statement_by_version(account, hversion)

      segment = Segment::HKSAL.new(3, hversion, acc)
      new_message(dialog, [segment])
    end

    def format_account_statement_by_version(account, hversion)
      if [4, 5, 6].include?(hversion)
        [account[:accountnumber], account[:subaccount], '280', account[:blz]].join(':')
      elsif hversion == 7
        [account[:iban], account[:bic], account[:accountnumber], account[:subaccount], '280', account[:blz]].join(':')
      else
        raise ArgumentError, "Unsupported HKSAL version #{hversion}"
      end
    end

    def get_statement(account, start_date, end_date)
      FinTS::Client.logger.info("Start fetching from #{start_date} to #{end_date}")

      dialog = new_dialog
      dialog.sync
      dialog.init

      msg = create_statement_message(dialog, account, start_date, end_date, nil)
      FinTS::Client.logger.debug("Send message: #{msg}")
      resp = dialog.send_msg(msg)
      touchdowns = resp.get_touchdowns(msg)
      responses = [resp]
      touchdown_counter = 1

      while touchdowns.include?(Segment::HKKAZ)
        FinTS::Client.logger.info("Fetching more results (#{touchdown_counter})...")
        msg = create_statement_message(dialog, account, start_date, end_date, touchdowns[Segment::HKKAZ])
        FinTS::Client.logger.debug("Send message: #{msg}")

        resp = dialog.send_msg(msg)
        responses << resp
        touchdowns = resp.get_touchdowns(msg)

        touchdown_counter += 1
      end

      FinTS::Client.logger.info('Fetching done.')
      re_data = /^[^@]*@([0-9]+?)@(.+)/m
      statement_response = ''
      responses.each do |r|
        seg = r.find_segment('HIKAZ')
        next unless seg
        match = re_data.match(seg)
        next unless match
        statement_response += match[2]
      end
      statement = Helper.mt940_to_array(statement_response)

      FinTS::Client.logger.debug("Statement: #{statement}")
      dialog.send_end
      statement
    end

    def create_statement_message(dialog, account, start_date, end_date, touchdown)
      hversion = dialog.hkkazversion

      acc = if [4, 5, 6].include?(hversion)
              [account[:accountnumber], account[:subaccount], '280', account[:blz]].join(':')
            elsif hversion == 7
              [account[:iban], account[:bic], account[:accountnumber], account[:subaccount], '280', account[:blz]].join(':')
            else
              raise ArgumentError, "Unsupported HKKAZ version #{hversion}"
            end

      segment = Segment::HKKAZ.new(3, hversion, acc, start_date, end_date, touchdown)
      new_message(dialog, [segment])
    end

    def get_holdings(account)
      # init dialog
      dialog = new_dialog
      dialog.sync
      dialog.init

      # execute job
      msg = create_get_holdings_message(dialog, account)
      FinTS::Client.logger.debug("Sending HKWPD: #{msg}")
      resp = dialog.send_msg(msg)
      FinTS::Client.logger.debug("Got HIWPD response: #{resp}")

      # end dialog
      dialog.send_end

      # find segment and split up to balance part
      seg = resp.find_segment('HIWPD')
      if seg
        mt535_lines = seg.lines
        # The first line contains a FinTS HIWPD header - drop it.
        mt535_lines.delete_at(0)
        mt535 = MT535Miniparser.new
        mt535.parse(mt535_lines)
      else
        FinTS::Client.logger.warn('No HIWPD response segment found - maybe account has no holdings?')
        []
      end
    end

    def create_get_holdings_message(dialog, account)
      hversion = dialog.hksalversion

      acc = if [1, 2, 3, 4, 5, 6].include?(hversion)
              [account[:accountnumber], account[:subaccount], '280', account[:blz]].join(':')
            elsif hversion == 7
              [account[:iban], account[:bic], account[:accountnumber], account[:subaccount], '280', account[:blz]].join(':')
            else
              raise ArgumentError, "Unsupported HKSAL version #{hversion}"
            end

      new_message(dialog, [Segment::HKWPD.new(3, hversion, acc)])
    end
  end
end
