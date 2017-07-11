module FinTS
  class Response
    RE_SEGMENTS = /'(?=[A-Z]{4,}:\d|')/
    RE_UNWRAP = /HNVSD:\d+:\d+\+@\d+@(.+)''/
    RE_SYSTEMID = /HISYN:\d+:\d+:\d+\+(.+)/
    RE_TANMECH = /\d{3}/

    def initialize(data)
      @response = unwrap(data)
      @segments = data.split(RE_SEGMENTS)
    end

    def split_for_data_groups(seg)
      seg.split(/\+(?<!\?\+)/)
    end

    def split_for_data_elements(deg)
      deg.split(/:(?<!\?:)/)
    end

    def get_summary_by_segment(name)
      if !['HIRMS', 'HIRMG'].include?(name)
        raise ArgumentError, 'Unsupported segment for message summary'
      end

      res = {}
      seg = find_segment(name)
      raise SegmentNotFoundError, "segment #{name}" if seg.nil?
      parts = split_for_data_groups(seg).drop(1)
      parts.each do |de|
        de = split_for_data_elements(de)
        res[de[0]] = de[2]
      end
      res
    end

    def successful?
      summary = get_summary_by_segment('HIRMG')
      summary.each do |code, msg|
        if code[0] == '9'
          return false
        end
      end
      return true
    end

    def get_dialog_id
      seg = self.find_segment('HNHBK')
      unless seg
        raise ArgumentError, 'Invalid response, no HNHBK segment'
      end
      get_segment_index(4, seg)
    end

    def get_system_id
      seg = find_segment('HISYN')
      match = RE_SYSTEMID.match(seg)
      raise ArgumentError, 'Could not find system_id' if match.nil?
      match[1]
    end

    def get_bank_name
      seg = find_segment('HIBPA')
      return nil if seg.nil?
      parts = split_for_data_groups(seg)
      return nil if parts.length <= 3
      parts[3]
    end

    def get_hkkaz_max_version
      get_segment_max_version('HIKAZS')
    end

    def get_hksal_max_version
      get_segment_max_version('HISALS')
    end

    def get_segment_index(idx, seg)
      seg = split_for_data_groups(seg)
      return seg[idx - 1] if seg.length > idx - 1
      nil
    end

    def get_segment_max_version(name)
      ret = 3
      segs = find_segments(name)
      segs.each do |s|
        parts = split_for_data_groups(s)
        segheader = split_for_data_elements(parts[0])
        current_version = segheader[2].to_i
        if current_version > ret
          ret = current_version
        end
      end
      ret
    end

    def get_supported_tan_mechanisms
      segs = self.find_segments('HIRMS')
      segs.each do |s|
        seg = split_for_data_groups(s).drop(1)
        seg.each do |segment_data_group|
          id, msg = segment_data_group.split('::', 2)
          if id == '3920'
            match = RE_TANMECH.match(msg)
            return [match[0]] if match
          end
        end
      end
      return false
    end
    
    def unwrap(data)
      match = RE_UNWRAP.match(data)
      match ? match[1] : data
    end

    def find_segment(name)
      find_segments(name, one: true)
    end

    def find_segments(name, one: false)
      found = one ? nil : []
      @segments.each do |segment|
        spl = segment.split(':', 2)
        if spl[0] == name
          return segment if one
          found << segment
        end
      end
      found
    end
    
    def find_segment_for_reference(name, ref)
      segs = find_segments(name)
      segs.each do |seg|
        segsplit = split_for_data_elements(split_for_data_groups(seg)[0])
        return seg if segsplit[3] == ref.segmentno.to_s
      end
      nil
    end

    def get_touchdowns(msg)
      touchdown = {}
      msg.encrypted_segments.each do |msgseg|
        seg = find_segment_for_reference('HIRMS', msgseg)
        next unless seg
        parts = split_for_data_groups(seg).drop(1)
        parts.each do |p|
          psplit = split_for_data_elements(p)
          next if psplit[0] != '3040'
          td = psplit[3]
          touchdown[msgseg.class] = Helper.fints_unescape(td)
        end
      end
      touchdown
    end
  end
end
