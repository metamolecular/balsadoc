require 'rubygems'
require 'bundler/setup'
require 'ebnf'
require 'ebnf/terminals'
require 'ebnf/peg/parser'

class Harness
    include EBNF::PEG::Parser

    def initialize
        ebnf = File.open(File.expand_path("../balsa.ebnf", __FILE__))

        @rules = EBNF.parse(ebnf).make_peg.ast
    end

    def test(input)
        begin
            parse(input, :String, @rules)
            nil
        rescue EBNF::PEG::Parser::Error => e
            input + ":" + e.message
        end
    end
end

failed = false

File.readlines('./pass.txt').each do |string|
    c = Harness::new()
    result = c.test(string)

    if !result.nil?
        failed = true

        puts "#{string} failed, but should have passed"
    end
end

File.readlines('./fail.txt').each do |string|
    c = Harness::new()
    result = c.test(string)

    if result.nil?
        failed = true
        
        puts "#{string} should have failed, but did not"
    end
end

if failed
    puts "FAIL"
else
    puts "PASS"
end
