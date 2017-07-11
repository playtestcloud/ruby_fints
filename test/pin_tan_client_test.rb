require 'test_helper'

class RubyFintsTest < Minitest::Test

  # this test tries to go as far as it can to retrieve a list of sepa accounts.
  # currently we don‘t have the fixtures to make this fully test the entire method.
  def test_it_raises_when_it_gets_a_bad_response
    Delorean.time_travel_to(Time.new(2017, 4, 20, 17, 17)) do
      # we have to mock random number generation
      Kernel.stubs(:rand).with(1000000..9999999).returns(9999999)

      response = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'bpd-allowedgv.txt'))
      stub_request(:post, "https://banking-bb6.de/fints30")
        .to_return(status: 200, body: Base64.encode64(response), headers: {})

      f = FinTS::PinTanClient.new('788000111', 'my?user', 'mypw', 'https://banking-bb6.de/fints30')
      FinTS::Client.logger.level = Logger::ERROR

      assert_raises FinTS::SegmentNotFoundError do
        f.get_sepa_accounts
      end
    end
  end
end
