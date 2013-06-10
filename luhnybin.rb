class Luhnybin

  attr_accessor :original_input, :input, :output, :delimiter, :delimiter_indexes

  MASK_CHAR = 'X'

  def initialize input
    @original_input = input.chomp!
    @input = @original_input
    @delimiter = ''
    @delimiter_indexes = []
    @output = @original_input.clone
  end

  def mask
    if original_input.size >= 14
      # we assign to input to be processed just digits and delimiters from original input
      @input = original_input.scan(/(\d+[\s|-]?)/).flatten.join
      process
    end
    output
  end

  def process
    # get delimiter character and the positions where is found
    get_delimiters
    # array representation of input, delimiters removed
    numbers = input.gsub(delimiter,'').split('').map &:to_i
    combinations = get_valid_numbers numbers
    combinations.each do |combination|
      luhn_check combination
    end
  end

  def luhn_check combination
    # we clone the combination in order to get the doubled values
    combination_with_doubled_values = luhn_double_values( combination )

    if is_luhn_sum_valid? combination_with_doubled_values
      valid_combination = combination.join
      masked_input = MASK_CHAR * valid_combination.size

      # we inject the delimiter in the positions found
      delimiter_indexes.each do |position|
        valid_combination.insert position, delimiter
        masked_input.insert position, delimiter
      end

      # Note: we loog through the valid_combination length in case some values were already replaced
      valid_combination.size.times do |index|
        # we replaced the valid_combination with the masked_input
        @output = @output.sub( valid_combination, masked_input )
        valid_combination[index] = MASK_CHAR
      end
    end
  end

  def luhn_double_values values
    doubled_values = values.clone
    index = 1
    # we iterate from the rightmoset value
    values.reverse_each do |value|
      if index.even?
        # we double the value
        doubled_value = value * 2 
        # we rest 9 from numbers higher than 9 (like adding the 2 digits)
        doubled_value -= 9 if doubled_value > 9
        # we replace the resulting value in the array
        doubled_values[-index] = doubled_value
      end
      index += 1
    end
    doubled_values
  end

  def is_luhn_sum_valid? values
    values.reduce(:+) % 10 == 0
  end

  # get all possible combinations of numbers with valid credit card number length
  def get_valid_numbers numbers
    valid_numbers = []
    # valid credit card number's length
    [ 16, 15, 14 ].each do |number_length|
      # if only one combination for that length
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
    # if we find spaces or hyphens
    if delimiter = input.match( /( |-)/ )
      @delimiter = delimiter[1]
      offset = 0
      # we iterate through the input to find all occurrences of delimiter
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