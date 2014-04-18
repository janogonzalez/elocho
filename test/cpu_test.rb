require 'minitest/autorun'
require 'elocho/cpu'

describe ElOcho::CPU do
  before do
    @cpu = ElOcho::CPU.new
  end

  describe "with a 6XNN instruction" do
    it "loads the NN value into register X" do
      @cpu.load [0x62, 0x82]
      @cpu.step
      @cpu.v[2].must_equal 0x82
      @cpu.pc.must_equal 0x202
    end
  end
end
