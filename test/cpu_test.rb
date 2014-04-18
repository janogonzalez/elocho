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
    it "sets register X to the value of register Y" do
      @cpu.load [0x62, 0x82,
                 0x81, 0x20]
      2.times { @cpu.step }
      @cpu.v[1].must_equal 0x82
      @cpu.pc.must_equal 0x204
    end
  end

  describe "with a 8XY1 instruction" do
    it "sets register X to the OR between registers X and Y" do
      @cpu.load [0x62, 0xCC,
                 0x61, 0x11,
                 0x81, 0x21]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0xDD
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY2 instruction" do
    it "sets register X to the AND between registers X and Y" do
      @cpu.load [0x62, 0xCC,
                 0x61, 0xAA,
                 0x81, 0x22]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x88
      @cpu.pc.must_equal 0x206
    end
  end

  describe "with a 8XY3 instruction" do
    it "sets register X to the XOR between registers X and Y" do
      @cpu.load [0x62, 0xCC,
                 0x61, 0xAA,
                 0x81, 0x23]
      3.times { @cpu.step }
      @cpu.v[1].must_equal 0x66
      @cpu.pc.must_equal 0x206
    end
  end
end
