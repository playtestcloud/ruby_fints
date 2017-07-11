module FinTS
  module Segment
    # HKEND (Dialogende)
    # Section C.4.1.2
    class HKEND < BaseSegment
      def initialize(segno, dialog_id)
        data = [dialog_id]
        super(segno, data)
      end

      protected

      def type
        'HKEND'
      end
      
      def version
        1
      end
    end
  end
end
