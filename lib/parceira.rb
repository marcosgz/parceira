# -*- encoding: utf-8 -*-

require 'rubygems'
require 'csv'
require 'i18n'
require 'active_support/lazy_load_hooks'
require 'active_support/i18n'
require 'active_support/inflector'
require 'active_support/core_ext/string'

require "parceira/version"
require "parceira/reader"

include ActiveSupport::Inflector

module Parceira
  def self.process(input, options={}, &block)
    Parceira::Reader.new(input, options.symbolize_keys, &block).process!
  end
end
