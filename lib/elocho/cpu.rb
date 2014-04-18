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
      when 0x6000
        register = (opcode & 0x0F00) >> 8
        value = opcode & 0x00FF

        v[register] = value
      end

      @pc += 0x002
    end

    private

    # Returns a word from memory starting at the given address.
    def word_at(address)
      @memory[address] << 8 | @memory[address + 1]
    end
  end
end
