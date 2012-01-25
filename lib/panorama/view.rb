# encoding: utf-8



require 'pathname'
require 'haml'
require 'panorama/view/content_for'



module Panorama
  class View
    Renderer = {
      '.haml' => proc { |locals|
        Haml::Engine.new(@template).render(self, locals) { |*args|
          yielded(*args)
        }
      }
    }

    def self.file(path, options=nil)
      options = options ? options.merge(:path => path) : {:path => path}

      new(File.read(path), options)
    end



    attr_reader :template
    attr_reader :path
    attr_reader :dir

    def initialize(template, options=nil)
      if options then
        @path         = options[:path] && Pathname(options[:path])
        @dir          = @path && @path.expand_path.dirname
        @renderer     = @path ? Renderer[@path.extname] : Renderer['.haml']
      else
        @path         = nil
        @dir          = nil
        @renderer     = Renderer['.haml']
      end
      @template     = template

      raise ArgumentError, "No renderer found for #{@path.extname.inspect}" unless @renderer
    end

    def find_partial(path)
      full_path = catch :path do
        (@dir+"_#{path}.html.haml").tap { |try| throw(:path, try) if try.readable? }
        (@dir+"#{path}.html.haml").tap { |try| throw(:path, try) if try.readable? }
      end
      raise ArgumentError, "Could not find partial #{path.inspect}" unless full_path

      View.file(full_path)
    end

    def partial(path, locals={})
      find_partial(path).render_internal(@content_for, locals)
    end

    def content_for(name, *args, &block)
      @content_for.add_content(name, capture_haml(&block))
      ""
    end

    def yielded(name, *args)
      @content_for.add_yield(name, *args)
    end

    def render(locals={})
      render_internal(ContentFor.new, locals).gsub(@content_for.regex) { |key|
        @content_for[key]
      }
    end
    alias to_s render

    def render_internal(content_for, locals)
      @content_for = content_for
      instance_exec(locals, &@renderer)
    end
  end
end
