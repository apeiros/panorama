# encoding: utf-8



module Panorama
  class View
    class ContentFor
      MaxRand = 1<<128

      attr_reader :yieldings, :contents, :prefix, :regex

      def initialize
        @yieldings  = {}
        @contents   = {}
        @prefix     = sprintf "__yielded_%32X_", rand(MaxRand)
        @regex      = /#{@prefix}\w+/
      end

      def [](key)
        @contents[key] || ""
      end

      def key(name)
        "#{@prefix}#{name}"
      end

      def add_content(name, string)
        (@contents[key(name)] ||= "") << string
      end

      def add_yield(name, *args)
        key = key(name)
        raise ArgumentError, "Already yielded #{name.inspect}" if @yieldings.has_key?(key)
        @yieldings[key] = [name, args]

        key
      end
    end
  end
end
