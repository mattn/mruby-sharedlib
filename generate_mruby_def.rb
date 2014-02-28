#!/usr/bin/env ruby

# install clang with llvm-config command
# clone ffi-clang to same directory as this file
# usage> ./generate_mruby_def.rb MRUBY_ROOT_PATH

ENV['LLVM_CONFIG'] = 'llvm-config'
$:.unshift './ffi-clang/lib'

require 'rubygems'
require './ffi-clang/lib/ffi/clang.rb'

MRUBY_ROOT = ARGV[0]

raise 'MRUBY_ROOT not found' if MRUBY_ROOT.nil? and not File.exist? MRUBY_ROOT

opts = ['-x', 'c-header', "-I#{MRUBY_ROOT}/include"]
Dir.glob("#{MRUBY_ROOT}/include/mruby/*.h").each do |v|
  opts << '-include' << v
end

index = FFI::Clang::Index.new
unit = index.parse_translation_unit "#{MRUBY_ROOT}/include/mruby.h", opts
functions = []
unit.cursor.visit_children do |c,p,u|
  functions.push c if
    c.kind == :cursor_function and
    c.linkage != :internal
  :recurse
end

functions = functions.map { |v| v.spelling }.select { |v| v =~ /^mrb_/ }.sort

File.open('mruby.def', 'w') do |f|
  f.puts 'LIBRARY mruby.dll'
  f.puts 'EXPORTS'
  functions.each do |v|
    f.puts "\t#{v}"
  end
end
