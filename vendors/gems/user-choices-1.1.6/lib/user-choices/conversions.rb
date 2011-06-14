#!/usr/bin/env ruby
#
#  Created by Brian Marick on 2007-08-06.
#  Copyright (c) 2007. All rights reserved.

module UserChoices
  class Conversion # :nodoc:
    @@subclasses = []
    def self.inherited(subclass)
      @@subclasses << subclass
    end
    
    def self.is_abstract
      @@subclasses.delete(self)
    end

    def self.record_for(conversion_tag, recorder)
      return if conversion_tag.nil?   # This simplifies caller.
      recorder << self.for(conversion_tag)
    end
    
    def self.for(conversion_tag)
      subclass = @@subclasses.find { |sc| sc.described_by?(conversion_tag) }
      user_claims(subclass) { "#{conversion_tag} doesn't describe any Conversion object." }
      subclass.new(conversion_tag)
    end
    
    def initialize(conversion_tag)
      @conversion_tag = conversion_tag
    end
    
    def self.described_by?(conversion_tag); subclass_responsibility; end
    def suitable?(actual); subclass_responsibility; end
    def description; subclass_responsibility; end
    
    def convert(value); value; end  # Some conversions are just for error-checking
    def does_length_check?; false; end
  end

  class NoOpConversion < Conversion # :nodoc:
    def self.described_by?(conversion_tag)
      conversion_tag == :string
    end

    def description; "a string"; end
    def suitable?(actual); true; end
    def convert(value); value; end
  end


  class ConversionToInteger < Conversion # :nodoc:
    def self.described_by?(conversion_tag)
      conversion_tag == :integer
    end
    
    def description; "an integer"; end
    
    def suitable?(actual)
      return true if actual.is_a?(Integer)
      actual.is_a?(String) and /^\d+$/ =~ actual # String check for better error message.
     end
     
    def convert(value); value.to_i; end
  end
  
  class ConversionToBoolean < Conversion # :nodoc:
    def self.described_by?(conversion_tag)
      conversion_tag == :boolean
    end

    def description; "a boolean"; end

    def suitable?(actual)
      return true if [true, false].include?(actual)
      return false unless actual.is_a?(String)
      ['true', 'false'].include?(actual.downcase)
    end
    
    def convert(value)
      case value
      when String: eval(value.downcase)
      else value
      end
    end
  end
  
  class SplittingConversion < Conversion # :nodoc:
    def self.described_by?(conversion_tag)
      conversion_tag == [:string]
    end

    def description; "a comma-separated list"; end
    
    def suitable?(actual)
      actual.is_a?(String) || actual.is_a?(Array)
    end
    
    def convert(value)
      case value
      when String: value.split(',')
      when Array: value
      end
    end
    
  end
  
  class LengthConversion < Conversion # :nodoc: 
    is_abstract
    
    attr_reader :required_length
    def initialize(conversion_tag)
      super
      @required_length = conversion_tag[:length]
    end
    
    def self.described_by?(conversion_tag, value_class)
      conversion_tag.is_a?(Hash) && conversion_tag[:length].is_a?(value_class)
    end
    
    def suitable?(actual)
      actual.respond_to?(:length) && yield
    end
    
    def does_length_check?; true; end
    
  end
  
  class ExactLengthConversion < LengthConversion # :nodoc: 
    def self.described_by?(conversion_tag)
      super(conversion_tag, Integer)
    end
    
    def description; "of length #{@required_length}"; end
    
    def suitable?(actual)
      super(actual) { actual.length == @required_length }
    end
  end

  class RangeLengthConversion < LengthConversion # :nodoc:
    def self.described_by?(conversion_tag)
      super(conversion_tag, Range)
    end

    def description; "a list whose length is in this range: #{@required_length}"; end
    
    def suitable?(actual)
      super(actual) { @required_length.include?(actual.length) }
    end
  end

  # Note: since some of the above classes are described_by? methods that 
  # respond_to :include, this class should be last, so that it's checked 
  # last.
  class ChoiceCheckingConversion < Conversion  # :nodoc:
    def self.described_by?(conversion_tag)
      conversion_tag.respond_to?(:include?)
    end
    
    def suitable?(actual); @conversion_tag.include?(actual); end
    def description; "one of #{friendly_list('or', @conversion_tag)}"; end
  end
end


