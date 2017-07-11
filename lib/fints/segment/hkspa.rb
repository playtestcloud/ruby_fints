module FinTS
  module Segment
    # HKSPA (SEPA-Kontoverbindung anfordern)
    # Section C.10.1.3
    class HKSPA < BaseSegment
      def initialize(segno, accno, subaccfeature, blz)
        data = if accno.nil?
                  ['']
                else
                  [[accno, subaccfeature, country_code, blz].join(':')]
                end
        super(segno, data)
      end

      protected

      def type
        'HKSPA'
      end
      
      def version
        1
      end
    end
  end
end
