module FinTS
  module Segment
    # HKWPD (Depotaufstellung anfordern)
    # Section C.4.3.1
    # Example: HKPWD:3:7+23456::280:10020030+USD+2'
    class HKWPD < BaseSegment
      def initialize(segno, version, account)
        # The spec allows the specification of currency and
        # quality of valuations, as shown in the docstring above.
        # However, both 1822direkt and CortalConsors reject the
        # call if these two are present, claiming an invalid input.
        # 'EUR'        # Währung der Depotaufstellung"
        # 2             # Kursqualität
        data = [account]
        super(segno, data)
        @version = version
      end

      protected

      def type
        'HKPWD'
      end
      
      def version
        @version
      end
    end
  end
end
