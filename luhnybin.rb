class Luhnybin

  attr_accessor :original_input, :input, :output, :delimiter, :delimiter_indexes

  def initialize input
    @original_input = input.chomp!
    @input = @original_input
    @delimiter = ''
    @delimiter_indexes = []
    @output = @original_input.clone
  end

  def mask
    if original_input.size >= 14
      @input = original_input.scan(/(\d+[\s|-]?)/).flatten.join
      luhn_check
    end
    output
  end

  def luhn_check
    get_delimiters
    numbers = input.gsub(delimiter,'').split('').map &:to_i
    combinations = get_valid_numbers numbers
    combinations.each do |combination|
      index = 1
      luhn_sum_combination = combination.clone
      luhn_sum_combination.reverse_each do |value|
        if index.even?
          doubled_value = ( value * 2 )
          if doubled_value.to_s.size == 2
            values = doubled_value.to_s.split('').map &:to_i
            doubled_value = values.reduce :+
          end
          luhn_sum_combination[-index] = doubled_value
        end
        index += 1
      end
      if luhn_sum_combination.reduce(:+) % 10 == 0
        valid_combination = combination.join
        masked_input = 'X'*valid_combination.size
        delimiter_indexes.each do |position|
          valid_combination.insert position, delimiter
          masked_input.insert position, delimiter
        end
        valid_combination.size.times do |index|
          @output = @output.sub( valid_combination, masked_input )
          valid_combination[index] = 'X'
        end
      end
    end
  end

  def get_valid_numbers numbers
    valid_numbers = []
    # valid credit card number's length
    [ 16, 15, 14 ].each do |number_length|
      # only one combination for that length
      if ( numbers.size - number_length ).zero?
        valid_numbers.push numbers
      else
        # add all possible combinations within the range of the length
        ( 0..( numbers.size - number_length ) ).each do |index|
          valid_numbers.push numbers[ index...( index + number_length ) ]
        end
      end
    end
    valid_numbers
  end

  def get_delimiters
    if delimiter = input.match( /( |-)/ )
      @delimiter = delimiter[1]
      offset = 0
      while input.index( @delimiter, offset )
        delimiter_indexes.push input.index( @delimiter, offset )
        offset = input.index( @delimiter, offset ) + 1
      end
    end
  end
end


while input = STDIN.gets
  luhnybin = Luhnybin.new input
  puts luhnybin.mask
end