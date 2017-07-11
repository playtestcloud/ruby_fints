module FinTS
  module Segment
    # HNVSK (Verschlüsselungskopf)
    # Section B.5.3
    class HNVSK < BaseSegment  
      COMPRESSION_NONE = 0
      SECURITY_SUPPLIER_ROLE = 1  # ISS

      def initialize(segno, blz, username, system_id, profile_version)
        data = [
          ['PIN', profile_version.to_s].join(':'),
          998,
          SECURITY_SUPPLIER_ROLE,
          ['1', '', system_id.to_s].join(':'),
          ['1', Time.now.strftime('%Y%m%d'), Time.now.strftime('%H%M%S')].join(':'),
          ['2', '2', '13', '@8@00000000', '5', '1'].join(':'),
          [country_code.to_s, blz, Helper.fints_escape(username), 'S', '0', '0'].join(':'),
          COMPRESSION_NONE
        ]
        super(segno, data)
      end

      protected

      def type
        'HNVSK'
      end
      
      def version
        3
      end
    end
  end
end
