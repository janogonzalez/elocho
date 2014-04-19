module ElOcho
  class CPU
    # V0 to VF: The 16 8-bit general purpose registers.
    attr_reader :v
    # PC: The 16-bit program counter register.
    attr_reader :pc
    # I: The 16-bit memory address register.
    attr_reader :i
    # The memory, 4k 8-bit cells.
    attr_reader :memory

    # Initializes a new CPU with the default values.
    def initialize
      @v = Array.new(16, 0x00)
      @pc = 0x200
      @i = 0x000
      @memory = Array.new(4096, 0x00)
    end

    # Loads a rom into memory.
    def load(rom)
      offset = 0

      rom.each do |byte|
        @memory[offset + 0x200] = byte
        offset += 1
      end
    end

    # Executes one step.
    def step
      opcode = word_at(@pc)

      case opcode & 0xF000
      when 0x1000
        address = opcode & 0x0FFF

        @pc = address
      when 0x3000
        register = (opcode & 0x0F00) >> 8
        value = opcode & 0x00FF

        if @v[register] == value
          @pc += 4
        else
          @pc += 2
        end
      when 0x4000
        register = (opcode & 0x0F00) >> 8
        value = opcode & 0x00FF

        if @v[register] != value
          @pc += 4
        else
          @pc += 2
        end
      when 0x5000
        if (opcode & 0x000F) == 0
          x = (opcode & 0x0F00) >> 8
          y = (opcode & 0x00F0) >> 4

          if @v[x] == @v[y]
            @pc += 4
          else
            @pc += 2
          end
        end
      when 0x6000
        register = (opcode & 0x0F00) >> 8
        value = opcode & 0x00FF

        @v[register] = value

        @pc += 0x002
      when 0x7000
        register = (opcode & 0x0F00) >> 8
        value = opcode & 0x00FF

        @v[register] = (@v[register] + value) & 0xFF

        @pc += 0x002
      when 0x8000
        to = (opcode & 0x0F00) >> 8
        from = (opcode & 0x00F0) >> 4

        case opcode & 0x000F
        when 0x0000
          @v[to] = @v[from]
        when 0x0001
          @v[to] = (@v[to] | @v[from])
        when 0x0002
          @v[to] = (@v[to] & @v[from])
        when 0x0003
          @v[to] = (@v[to] ^ @v[from])
        when 0x0004
          result = @v[to] + @v[from]

          @v[0xF] = (result > 0xFF) ? 1 : 0
          @v[to] = result & 0xFF
        when 0x0005
          result = @v[to] - @v[from]

          @v[0xF] = (@v[to] > @v[from]) ? 1 : 0
          @v[to] = result & 0xFF
        when 0x0006
          @v[0xF] = @v[to] & 0x01
          @v[to] = @v[to] >> 1
        when 0x0007
          result = @v[from] - @v[to]

          @v[0xF] = (@v[from] > @v[to]) ? 1 : 0
          @v[to] = result & 0xFF
        when 0x0008
          @v[0xF] = (@v[to] & 0x80) >> 7
          @v[to] = (@v[to] << 1) & 0xFF
        end

        @pc += 0x002
      when 0xA000
        address = opcode & 0x0FFF

        @i = address
        @pc += 2
      when 0xB000
        address = opcode & 0x0FFF

        @pc = (@v[0] + address) & 0xFFF
      end
    end

    private

    # Returns a word from memory starting at the given address.
    def word_at(address)
      @memory[address] << 8 | @memory[address + 1]
    end
  end
end
