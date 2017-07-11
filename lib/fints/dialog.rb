module FinTS
  class DialogError < StandardError; end

  class Dialog
    attr_accessor :system_id
    attr_accessor :dialog_id
    attr_accessor :msg_no
    attr_accessor :tan_mechs
    attr_accessor :hkkazversion
    attr_accessor :hksalversion

    def initialize(blz, username, pin, system_id, connection)
      @blz = blz
      @username = username
      @pin = pin
      @system_id = system_id
      @connection = connection
      @msg_no = 1
      @dialog_id = 0
      @hksalversion = 6
      @hkkazversion = 6
      @tan_mechs = []
    end

    def sync
      FinTS::Client.logger.info('Initialize SYNC')

      seg_identification = Segment::HKIDN.new(3, @blz, @username, 0)
      seg_prepare = Segment::HKVVB.new(4)
      seg_sync = Segment::HKSYN.new(5)

      msg_sync = Message.new(@blz, @username, @pin, @system_id, @dialog_id, @msg_no, [
        seg_identification,
        seg_prepare,
        seg_sync
      ])

      FinTS::Client.logger.debug("Sending SYNC: #{msg_sync}")
      resp = send_msg(msg_sync)
      FinTS::Client.logger.debug("Got SYNC response: #{resp}")
      @system_id = resp.get_system_id
      @dialog_id = resp.get_dialog_id
      @bankname = resp.get_bank_name
      @hksalversion = resp.get_hksal_max_version
      @hkkazversion = resp.get_hkkaz_max_version
      @tan_mechs = resp.get_supported_tan_mechanisms

      FinTS::Client.logger.debug("Bank name: #{@bankname}")
      FinTS::Client.logger.debug("System ID: #{@system_id}")
      FinTS::Client.logger.debug("Dialog ID: #{@dialog_id}")
      FinTS::Client.logger.debug("HKKAZ max version: #{@hkkazversion}")
      FinTS::Client.logger.debug("HKSAL max version: #{@hksalversion}")
      FinTS::Client.logger.debug("TAN mechanisms: #{@tan_mechs}")
      send_end
    end

    def init
      FinTS::Client.logger.info('Initialize Dialog')
      seg_identification = Segment::HKIDN.new(3, @blz, @username, @system_id)
      seg_prepare = Segment::HKVVB.new(4)

      msg_init = Message.new(@blz, @username, @pin, @system_id, @dialog_id, @msg_no, [
        seg_identification,
        seg_prepare,
      ], @tan_mechs)
      FinTS::Client.logger.debug("Sending INIT: #{msg_init}")
      resp = send_msg(msg_init)
      FinTS::Client.logger.debug("Got INIT response: #{resp}")

      @dialog_id = resp.get_dialog_id
      FinTS::Client.logger.info("Received dialog ID: #{@dialog_id}")

      @dialog_id
    end

    def send_msg(msg)
      FinTS::Client.logger.info('Sending Message')
      msg.msg_no = @msg_no
      msg.dialog_id = @dialog_id

      resp = Response.new(@connection.send_msg(msg))
      if !resp.successful?
        raise DialogError, resp.get_summary_by_segment('HIRMG')
      end
      @msg_no += 1
      resp
    end

    def send_end
      FinTS::Client.logger.info('Initialize END')

      msg_end = Message.new(@blz, @username, @pin, @system_id, @dialog_id, @msg_no, [
        Segment::HKEND.new(3, @dialog_id)
      ])
      FinTS::Client.logger.debug("Sending END: #{msg_end}")
      resp = send_msg(msg_end)
      FinTS::Client.logger.debug("Got END response: #{resp}")
      FinTS::Client.logger.info('Resetting dialog ID and message number count')
      @dialog_id = 0
      @msg_no = 1
      resp
    end
  end
end
