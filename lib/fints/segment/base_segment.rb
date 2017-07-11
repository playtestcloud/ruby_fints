class BaseSegment
  attr_accessor :segmentno

  def initialize(segmentno, data)
    @segmentno = segmentno
    @data = data
  end

  def to_s
    res = [type, @segmentno, version].join(':')
    @data.each do |d|
      res += "+#{d}"
    end
    res + "'"
  end

  protected

  def type
    raise NotImplementedError
  end
  
  def version
    raise NotImplementedError
  end

  def country_code
    280
  end
end
