# frozen_string_literal: true

require 'rubygems'
require 'csv'
require 'i18n'
require 'active_support/lazy_load_hooks'
require 'active_support/i18n'
require 'active_support/inflector'
require 'active_support/core_ext/string'

require 'parceira/version'
require 'parceira/reader'

module Parceira
  def self.process(input, options = {}, &block)
    records = Parceira::Reader.new(input, options.symbolize_keys).process!
    if block_given?
      records.each { |record| block.call(record) }
    else
      records
    end
  end
end
