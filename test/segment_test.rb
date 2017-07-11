require 'test_helper'

class SegmentTest < Minitest::Test
  def test_hkend
    hkend = FinTS::Segment::HKEND.new(5, 20)
    assert_equal "HKEND:5:1+20'", hkend.to_s
  end

  def test_hkidn
    hkidn = FinTS::Segment::HKIDN.new(5, '123456', 'username')
    assert_equal "HKIDN:5:2+280:123456+username+0+1'", hkidn.to_s
  end

  def test_hkkaz
    date_start = Date.new(2017, 2, 1)
    date_end = Date.new(2017, 2, 28)
    hkkaz = FinTS::Segment::HKKAZ.new(5, 6, '123456', date_start, date_end, nil)
    assert_equal "HKKAZ:5:6+123456+N+20170201+20170228++'", hkkaz.to_s
  end

  def test_hkwpd
    account = ['123456', nil, '280', '778000111'].join(':')
    hkpwd = FinTS::Segment::HKWPD.new(5, 6, account)
    assert_equal "HKPWD:5:6+123456::280:778000111'", hkpwd.to_s
  end

  def test_hkspa
    hkspa = FinTS::Segment::HKSPA.new(5, nil, nil, nil)
    assert_equal "HKSPA:5:1+'", hkspa.to_s
  end

  def test_hkspa_with_account_number
    hkspa = FinTS::Segment::HKSPA.new(5, '123456', nil, '778000111')
    assert_equal "HKSPA:5:1+123456::280:778000111'", hkspa.to_s
  end

  def test_hksyn
    hksyn = FinTS::Segment::HKSYN.new(5)
    assert_equal "HKSYN:5:3+0'", hksyn.to_s
  end

  def test_hkvvb
    hkvvb = FinTS::Segment::HKVVB.new(5)
    assert_equal "HKVVB:5:3+0+0+1+ruby_fints+#{FinTS::VERSION}'", hkvvb.to_s
  end

  def test_hnhbk
    hnhbk = FinTS::Segment::HNHBK.new(125, 2, 5)
    assert_equal "HNHBK:1:3+000000000156+300+2+5'", hnhbk.to_s
  end

  def test_hnhbs
    hnhbs = FinTS::Segment::HNHBS.new(2, 5)
    assert_equal "HNHBS:2:1+5'", hnhbs.to_s
  end

  def test_hnsha
    secref = 9999999
    pin = 'abc+123?\'' # this will be escaped when serializing the segment
    hnsha = FinTS::Segment::HNSHA.new(5, secref, pin)
    assert_equal "HNSHA:5:2+9999999++abc?+123???''", hnsha.to_s
  end

  def test_hnshk
    Delorean.time_travel_to(Time.new(2017, 4, 20, 17, 17)) do
      secref = 9999999
      hnshk = FinTS::Segment::HNSHK.new(5, secref, '778000111', 'my?user', 1, 123)
      assert_equal "HNSHK:5:4+PIN:123+999+9999999+1+1+1::1+1+1:20170420:171700+1:999:1+6:10:16+280:778000111:my??user:S:0:0'", hnshk.to_s
    end
  end

  def test_hnvsd
    Delorean.time_travel_to(Time.new(2017, 4, 20, 17, 17)) do
      secref = 9999999
      hnshk = FinTS::Segment::HNSHK.new(5, secref, '778000111', 'my?user', 1, 123)
      
      hnvsd = FinTS::Segment::HNVSD.new(999, '')
      hnvsd.set_data(hnvsd.encoded_data + hnshk.to_s)
      assert_equal "HNVSD:999:1+@104@HNSHK:5:4+PIN:123+999+9999999+1+1+1::1+1+1:20170420:171700+1:999:1+6:10:16+280:778000111:my??user:S:0:0''", hnvsd.to_s
    end
  end

  def test_hnvsk
    Delorean.time_travel_to(Time.new(2017, 4, 20, 17, 17)) do
      hnvsk = FinTS::Segment::HNVSK.new(5, '778000111', 'my?user', 1, 123)
      assert_equal "HNVSK:5:3+PIN:123+998+1+1::1+1:20170420:171700+2:2:13:@8@00000000:5:1+280:778000111:my??user:S:0:0+0'", hnvsk.to_s
    end
  end

end
