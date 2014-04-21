module ElOcho
  class CPU
    # Size of the memory
    MEMORY_SIZE = 4096
    # Start address for the programs
    PROGRAM_MEMORY_START = 0x200

    # V0 to VF: The 16 8-bit general purpose registers.
    attr_reader :v
    # PC: The 12-bit program counter register.
    attr_reader :pc
    # I: The 12-bit memory address register.
    attr_reader :i
    # The memory, 4k 8-bit cells.
    attr_reader :memory

    # Initializes a new CPU with the default values.
    def initialize
      @v = Array.new(16, 0x00)
      @pc = PROGRAM_MEMORY_START
      @i = 0x000
      @memory = Array.new(MEMORY_SIZE, 0x00)
    end

    # Loads a rom into memory.
    def load(rom)
      index = 0

      rom.each do |byte|
        @memory[index + PROGRAM_MEMORY_START] = byte
        index += 1
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
        x = (opcode & 0x0F00) >> 8
        value = opcode & 0x00FF

        @pc += 2  if @v[x] == value
        @pc += 2
      when 0x4000
        x = (opcode & 0x0F00) >> 8
        value = opcode & 0x00FF

        @pc += 2  if @v[x] != value
        @pc += 2
      when 0x5000
        if (opcode & 0x000F) == 0
          x = (opcode & 0x0F00) >> 8
          y = (opcode & 0x00F0) >> 4

          @pc += 2  if @v[x] == @v[y]
          @pc += 2
        end
      when 0x6000
        x = (opcode & 0x0F00) >> 8
        value = opcode & 0x00FF

        @v[x] = value

        @pc += 2
      when 0x7000
        x = (opcode & 0x0F00) >> 8
        value = opcode & 0x00FF

        @v[x] = (@v[x] + value) & 0xFF

        @pc += 2
      when 0x8000
        x = (opcode & 0x0F00) >> 8
        y = (opcode & 0x00F0) >> 4

        case opcode & 0x000F
        when 0x0000
          @v[x] = @v[y]
        when 0x0001
          @v[x] = (@v[x] | @v[y])
        when 0x0002
          @v[x] = (@v[x] & @v[y])
        when 0x0003
          @v[x] = (@v[x] ^ @v[y])
        when 0x0004
          result = @v[x] + @v[y]

          @v[0xF] = (result > 0xFF) ? 1 : 0
          @v[x] = result & 0xFF
        when 0x0005
          result = @v[x] - @v[y]

          @v[0xF] = (@v[x] > @v[y]) ? 1 : 0
          @v[x] = result & 0xFF
        when 0x0006
          @v[0xF] = @v[x] & 0x01
          @v[x] = @v[x] >> 1
        when 0x0007
          result = @v[y] - @v[x]

          @v[0xF] = (@v[y] > @v[x]) ? 1 : 0
          @v[x] = result & 0xFF
        when 0x0008
          @v[0xF] = (@v[x] & 0x80) >> 7
          @v[x] = (@v[x] << 1) & 0xFF
        end

        @pc += 0x002
      when 0x9000
        if (opcode & 0x000F) == 0
          x = (opcode & 0x0F00) >> 8
          y = (opcode & 0x00F0) >> 4

          @pc += 2  if @v[x] != @v[y]
          @pc += 2
        end
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
