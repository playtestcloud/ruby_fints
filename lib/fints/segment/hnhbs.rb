module FinTS
  module Segment
    # HNHBS (Nachrichtenabschluss)
    # Section B.5.3
    class HNHBS < BaseSegment
      def initialize(segno, msgno)
        data = [msgno.to_s]
        super(segno, data)
      end

      protected

      def type
        'HNHBS'
      end
      
      def version
        1
      end
    end
  end
end
