module FinTS
  module Segment
    # HKIDN (Identifikation)
    # Section C.3.1.2
    class HKIDN < BaseSegment
      def initialize(segment_number, blz, username, system_id=0, customerid=1)
        data = ["#{country_code}:#{blz}", Helper.fints_escape(username), system_id, customerid]
        super(segment_number, data)
      end

      protected

      def type
        'HKIDN'
      end
      
      def version
        2
      end
    end
  end
end
