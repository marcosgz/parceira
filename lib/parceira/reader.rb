# -*- encoding: utf-8 -*-
module Parceira
  class Reader
    DEFAULT_OPTIONS = {
      # CSV options
      col_sep:            ',',
      row_sep:            $/,
      quote_char:         '"',
      # Header
      headers:            true,
      headers_included:   true,
      key_mapping:        nil,
      file_encoding:      nil,
      # Values
      reject_blank:       true,
      reject_nil:         false,
      reject_zero:        false,
      reject_matching:    nil,
      convert_to_numeric: true,
    }
    attr_reader :options


    def initialize(input, options, &block)
      @input    = input
      @options  = DEFAULT_OPTIONS.merge(options)
    end


    def process!
      if input_file.nil? && @input.is_a?(String)
        data = CSV.parse(@input, csv_options) # content is already in memory. Process with CSV
        header_data = data.shift if options[:headers_included] # Remove header row
        header_keys = \
          if options[:headers] == true
            self.parse_header( header_data )
          elsif options[:headers].is_a?(Array)
            options[:headers]
          end
        data.map do |arr|
          values = parse_values(arr)
          if header_keys
            convert_to_hash(header_keys, values)
          else
            values
          end
        end
      elsif input_file.is_a?(File)
        output = []
        begin
          $/ = options[:row_sep]
          # Build header
          header_data = input_file.readline.to_s.chomp(options[:row_sep]) if options[:headers_included] # Remove header row
          header_keys = \
            if options[:headers] == true
              data = CSV.parse(header_data, self.csv_options)
              self.parse_header( data )
            elsif options[:headers].is_a?(Array)
              options[:headers]
            end

          # now on to processing all the rest of the lines in the CSV file:
          while !input_file.eof?    # we can't use f.readlines() here, because this would read the whole file into memory at once, and eof => true
            values = parse_values( CSV.parse(input_file.readline.chomp, csv_options) )
            if header_keys
              output << convert_to_hash(header_keys, values)
            else
              output << values
            end
          end
        ensure
          $/ = $/
        end
        output
      end
    end

  protected
    def convert_to_hash(header, values)
      header.each_with_index.inject({}) do |r, (key, index)|
        value = values[index]
        if options[:reject_nil] && value.nil?
        else
          r[key] = value
        end
        r
      end
    end

    def parse_values(arr)
      arr.flatten.map do |v|
        value = \
          if options[:convert_to_numeric]
            case v
            when /^[+-]?\d+\.\d+$/
              v.to_f
            when /^[+-]?\d+$/
              v.to_i
            else
              v.to_s.strip
            end
          else
            v.to_s.strip
          end
        value = nil if options[:reject_blank] && value.blank?
        value = nil if options[:reject_zero]  && value.respond_to?(:zero?) && value.zero?
        value = nil if options[:reject_matching] && value =~ options[:reject_matching]
        value
      end
    end

    def parse_header(arr)
      arr.flatten.each_with_index.inject([]) do |arr, (value, index)|
        v = \
          if (str=value.to_s.parameterize('_')).present?
            str.to_sym
          else
            "field_#{index.next}".to_sym
          end
        v = options[:key_mapping][v] if options[:key_mapping].is_a?(Hash) && options[:key_mapping].has_key?(v)
        arr.push(v)
      end
    end

    def input_file
      @input_file ||= \
        case @input
        when File
          @input
        when String
          if File.exists?(@input)
            File.open(@input, "r:#{self.charset}")
          end
        end
    end


    def charset
      options[:file_encoding] || begin
        filename = \
          case @input
          when String
            @input if File.exists?(@input)
          when File
            @input.path
          end
        if filename
          IO.popen(['file', '--brief', '--mime', filename]).read.chomp.match(/charset=([^\s]+)/) { $1 }
        else
          default_charset
        end
      rescue
        default_charset
      end
    end


    def csv_options
      options.select do |k,v|
        [
          :col_sep,
          :row_sep,
          :quote_char,
          :field_size_limit,
          :converters,
          :unconverted_fields,
          :skip_blanks,
          :force_quotes
        ].include?(k)
      end
    end


    def default_charset
      'utf-8'
    end

  end
end
