module FinTS
  module Segment
    # HNVSD (Verschlüsselte Daten)
    # Section B.5.4
    class HNVSD < BaseSegment
      attr_reader :encoded_data

      def initialize(segno, encoded_data)
        @encoded_data = encoded_data
        data = ["@#{encoded_data.length}@#{encoded_data}"]
        super(segno, data)
      end

      def set_data(encoded_data)
        @encoded_data = encoded_data
        @data = ["@#{encoded_data.length}@#{encoded_data}"]
      end

      protected

      def type
        'HNVSD'
      end
      
      def version
        1
      end
    end
  end
end
