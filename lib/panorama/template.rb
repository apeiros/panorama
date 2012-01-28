# encoding: utf-8



require 'panorama/rendercontext'



module Panorama
  class Template
    def self.file(path, encoding=nil)
      new(File.read(path, :encoding => encoding), path, 1)
    end

    attr_reader :string
    attr_reader :file
    attr_reader :line

    def initialize(template, file="(String)", line=1)
      @string = template
      @file   = String(file)
      @line   = Integer(line)
    end

    def render(locals={})
      RenderContext.render(self, nil, locals, {})
    end
  end
end
