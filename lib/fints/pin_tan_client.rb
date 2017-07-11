module FinTS
  class PinTanClient < Client
    def initialize(blz, username, pin, server)
      @blz = blz
      @username = username
      @pin = pin
      @connection = HTTPSConnection.new(server)
      @system_id = 0
      super()
    end

    protected

    def new_dialog
      Dialog.new(@blz, @username, @pin, @system_id, @connection)
    end

    def new_message(dialog, segments)
      Message.new(@blz, @username, @pin, dialog.system_id, dialog.dialog_id, dialog.msg_no, segments, dialog.tan_mechs)
    end
  end
end
