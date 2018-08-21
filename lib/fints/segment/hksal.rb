module FinTS
  module Segment
    # HKSAL (Kontosaldo)
    # Refs: http://www.hbci-zka.de/dokumente/spezifikation_deutsch/fintsv3/FinTS_3.0_Messages_Geschaeftsvorfaelle_2015-08-07_final_version.pdf
    # Section C.2.1.2
    class HKSAL < BaseSegment
      def initialize(segno, version, account)
        @version = version
        data = [
          account,
          'N'
        ]
        super(segno, data)
      end

      protected

      def type
        'HKSAL'
      end

      def version
        @version
      end
    end
  end
end
