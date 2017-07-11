module FinTS
  module Segment
    # HKVVB (Verarbeitungsvorbereitung)
    # Section C.3.1.3
    class HKVVB < BaseSegment
      LANG_DE = 1
      LANG_EN = 2
      LANG_FR = 3

      def initialize(segment_no, lang: LANG_DE)
        data = [0, 0, lang, Helper.fints_escape(FinTS::GEM_NAME), Helper.fints_escape(FinTS::VERSION)]
        super(segment_no, data)
      end

      protected

      def type
        'HKVVB'
      end
      
      def version
        3
      end
    end
  end
end
