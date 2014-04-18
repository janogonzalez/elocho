require 'minitest/autorun'
require 'elocho/cpu'

describe ElOcho::CPU do
  before do
    @cpu = ElOcho::CPU.new
  end

  describe "with a 1NNN instruction" do
    it "loads the NNN value into the PC register" do
      @cpu.load [0x14, 0x82]
      @cpu.step
      @cpu.pc.must_equal 0x482
    end
  end

  describe "with a 6XNN instruction" do
    it "loads the NN value into register VX" do
      @cpu.load [0x62, 0x82]
      @cpu.step
      @cpu.v[2].must_equal 0x82
      @cpu.pc.must_equal 0x202
    end
  end

  describe "with a 7XNN instruction" do
    it "adds the NN value into register VX" do
      @cpu.load [0x72, 0x80,
                 0x72, 0x02]
      2.times { @cpu.step }
      @cpu.v[2].must_equal 0x82
      @cpu.pc.must_equal 0x204
    end

    it "applies the 0xFF mask to the result" do
      @cpu.load [0x72, 0xFF,
                 0x72, 0x82]
      2.times { @cpu.step }
      @cpu.v[2].must_equal 0x81
      @cpu.pc.must_equal 0x204
    end
  end

  describe "with a 8XY0 instruction" do
    it "sets register VX to the value of register VY" do
      @cpu.load [0x62, 0x82,
                 0x81, 0x20]
      2.times { @cpu.step }
      @cpu.v[1].must_equal 0x82
      @cpu.pc.must_equal 0x204
    end
  end

  describe "with a 8XY1 instruction" do
    it "sets register VX to the OR between registers VX and VY" do
      @cpu.load [0x62, 0xCC,
                 0x61, 0x11,
                 0x81, 0x21]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0xDD
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY2 instruction" do
    it "sets register VX to the AND between registers VX and VY" do
      @cpu.load [0x62, 0xCC,
                 0x61, 0xAA,
                 0x81, 0x22]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x88
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY3 instruction" do
    it "sets register VX to the XOR between registers VX and VY" do
      @cpu.load [0x62, 0xCC,
                 0x61, 0xAA,
                 0x81, 0x23]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x66
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a ANNN instruction" do
    it "loads the NNN value into the I register" do
      @cpu.load [0xA4, 0x82]
      @cpu.step
      @cpu.i.must_equal 0x482
      @cpu.pc.must_equal 0x202
    end
  end

  describe "with a BNNN instruction" do
    it "loads the sum of the NNN value and V0 register into the PC register" do
      @cpu.load [0x60, 0x82,
                 0xB1, 0x01]
      2.times { @cpu.step }
      @cpu.pc.must_equal 0x183
    end
  end
end
