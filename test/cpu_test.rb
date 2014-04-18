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

  describe "with a 7XNN instruction" do
    it "adds the NN value into register X" do
      @cpu.load [0x72, 0x80, 0x72, 0x02, 0x72]
      @cpu.step
      @cpu.v[2].must_equal 0x80
      @cpu.pc.must_equal 0x202
      @cpu.step
      @cpu.v[2].must_equal 0x82
      @cpu.pc.must_equal 0x204
    end

    it "applies the 0xFF mask to the result" do
      @cpu.load [0x72, 0xFF, 0x72, 0x82]
      @cpu.step
      @cpu.step
      @cpu.v[2].must_equal 0x81
      @cpu.pc.must_equal 0x204
    end
  end

  describe "with a 8XY0 instruction" do
    it "sets register X to the value of register Y" do
      @cpu.load [0x62, 0x82, 0x81, 0x20]
      @cpu.step
      @cpu.step
      @cpu.v[1].must_equal 0x82
      @cpu.pc.must_equal 0x204
    end
  end
end
