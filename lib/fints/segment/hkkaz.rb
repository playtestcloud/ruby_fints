module FinTS
  module Segment
    # HKKAZ (Kontoumsätze)
    # Refs: http://www.hbci-zka.de/dokumente/spezifikation_deutsch/fintsv3/FinTS_3.0_Messages_Geschaeftsvorfaelle_2015-08-07_final_version.pdf
    # Section C.2.1.1.1.2
    class HKKAZ < BaseSegment
      def initialize(segno, version, account, date_start, date_end, touchdown)
        @version = version
        data = [
          account,
          'N',
          date_start.strftime('%Y%m%d'),
          date_end.strftime('%Y%m%d'),
          '',
          touchdown ? Helper.fints_escape(touchdown) : ''
        ]
        super(segno, data)
      end

      protected

      def type
        'HKKAZ'
      end

      def version
        @version
      end
    end
  end
end
