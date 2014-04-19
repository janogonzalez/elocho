require 'minitest/autorun'
require 'elocho/cpu'

describe ElOcho::CPU do
  before do
    @cpu = ElOcho::CPU.new
  end

  describe "with a 1NNN instruction" do
    it "sets PC to NNN" do
      @cpu.load [0x14, 0x82]
      @cpu.step
      @cpu.pc.must_equal 0x482
    end
  end

  describe "with a 3XNN instruction" do
    it "skips the next instruction if VX == NN" do
      @cpu.load [0x62, 0x82,
                 0x32, 0x82]
      2.times { @cpu.step }
      @cpu.pc.must_equal 0x206
    end

    it "continues if the next instruction is VX != NN" do
      @cpu.load [0x62, 0x82,
                 0x32, 0x81]
      2.times { @cpu.step }
      @cpu.pc.must_equal 0x204
    end
  end

  describe "with a 4XNN instruction" do
    it "skips the next instruction if VX != NN" do
      @cpu.load [0x62, 0x82,
                 0x42, 0x81]
      2.times { @cpu.step }
      @cpu.pc.must_equal 0x206
    end

    it "continues if the next instruction is VX == NN" do
      @cpu.load [0x62, 0x82,
                 0x42, 0x82]
      2.times { @cpu.step }
      @cpu.pc.must_equal 0x204
    end
  end

  describe "with a 6XNN instruction" do
    it "sets VX to NN" do
      @cpu.load [0x62, 0x82]
      @cpu.step
      @cpu.v[2].must_equal 0x82
      @cpu.pc.must_equal 0x202
    end
  end

  describe "with a 7XNN instruction" do
    it "sets VX to VX + NN" do
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
    it "sets VX to VY" do
      @cpu.load [0x62, 0x82,
                 0x81, 0x20]
      2.times { @cpu.step }
      @cpu.v[1].must_equal 0x82
      @cpu.pc.must_equal 0x204
    end
  end

  describe "with a 8XY1 instruction" do
    it "sets VX to the bitwise OR between VX and VY" do
      @cpu.load [0x62, 0xCC,
                 0x61, 0x11,
                 0x81, 0x21]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0xDD
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY2 instruction" do
    it "sets VX to the bitwise AND between VX and VY" do
      @cpu.load [0x62, 0xCC,
                 0x61, 0xAA,
                 0x81, 0x22]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x88
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY3 instruction" do
    it "sets VX to the bitwise XOR between VX and VY" do
      @cpu.load [0x62, 0xCC,
                 0x61, 0xAA,
                 0x81, 0x23]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x66
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY4 instruction" do
    it "sets VX to VX + VY" do
      @cpu.load [0x62, 0x80,
                 0x61, 0x02,
                 0x81, 0x24]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x82
      @cpu.v[0xF].must_equal 0x00
      @cpu.pc.must_equal 0x206
    end

    it "sets VF when there is a carry" do
      @cpu.load [0x62, 0xFF,
                 0x61, 0x03,
                 0x81, 0x24]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x02
      @cpu.v[0xF].must_equal 0x01
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY5 instruction" do
    it "sets VX to VX - VY" do
      @cpu.load [0x62, 0x02,
                 0x61, 0x84,
                 0x81, 0x25]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x82
      @cpu.v[0xF].must_equal 0x01
      @cpu.pc.must_equal 0x206
    end

    it "does not set VF when there is a borrow" do
      @cpu.load [0x62, 0xFF,
                 0x61, 0x03,
                 0x81, 0x25]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x04
      @cpu.v[0xF].must_equal 0x00
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY6 instruction" do
    it "sets VX to VX >> 1" do
      @cpu.load [0x62, 0x04,
                 0x82, 0x06]
      2.times { @cpu.step }
      @cpu.v[2].must_equal 0x02
      @cpu.v[0xF].must_equal 0x00
      @cpu.pc.must_equal 0x204
    end

    it "sets VF when the least significant bit is 1" do
      @cpu.load [0x62, 0xFF,
                 0x82, 0x06]
      2.times { @cpu.step }
      @cpu.v[2].must_equal 0x7F
      @cpu.v[0xF].must_equal 0x01
      @cpu.pc.must_equal 0x204
    end
  end

  describe "with a 8XY7 instruction" do
    it "sets VX to VY - VX" do
      @cpu.load [0x62, 0x84,
                 0x61, 0x02,
                 0x81, 0x27]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x82
      @cpu.v[0xF].must_equal 0x01
      @cpu.pc.must_equal 0x206
    end

    it "does not set VF when there is a borrow" do
      @cpu.load [0x62, 0x03,
                 0x61, 0xFF,
                 0x81, 0x27]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x04
      @cpu.v[0xF].must_equal 0x00
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY8 instruction" do
    it "sets VX to VX << 1" do
      @cpu.load [0x62, 0x04,
                 0x82, 0x08]
      2.times { @cpu.step }
      @cpu.v[2].must_equal 0x08
      @cpu.v[0xF].must_equal 0x00
      @cpu.pc.must_equal 0x204
    end

    it "sets VF when the most significant bit is 1" do
      @cpu.load [0x62, 0xFF,
                 0x82, 0x08]
      2.times { @cpu.step }
      @cpu.v[2].must_equal 0xFE
      @cpu.v[0xF].must_equal 0x01
      @cpu.pc.must_equal 0x204
    end
  end

  describe "with a ANNN instruction" do
    it "sets I to NNN" do
      @cpu.load [0xA4, 0x82]
      @cpu.step
      @cpu.i.must_equal 0x482
      @cpu.pc.must_equal 0x202
    end
  end

  describe "with a BNNN instruction" do
    it "sets PC to NNN + V0" do
      @cpu.load [0x60, 0x82,
                 0xB1, 0x01]
      2.times { @cpu.step }
      @cpu.pc.must_equal 0x183
    end
  end
end
