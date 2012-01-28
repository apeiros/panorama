# encoding: utf-8



module Panorama
  # Finds templates
  class Finder

    attr_reader :sources
    def initialize(sources, suffixes)
      @sources = sources.flat_map { |source|
        if source.is_a?(Range) then
          result = [source.begin]
          result << File.dirname(result.last) until result.last == source.end
          result
        else
          source
        end
      }
      @suffixes = suffixes
    end

    def find(name, priority_paths=nil)
      each_path(name, priority_paths).find { |path| File.file?(path) }
    end

    def each_path(name, priority_paths=nil)
      return enum_for(__method__, name, priority_paths) unless block_given?

      sources = priority_paths ? priority_paths+@sources : @sources
      sources.each do |dir|
        @suffixes.each do |suffix|
          yield(File.expand_path("#{dir}/#{name}.#{suffix}"))
        end
      end
    end
  end
end
