# encoding: utf-8



require 'haml'
require 'panorama/contentfor'
require 'panorama/finder'



module Panorama
  class RenderContext
    StandardSuffixes  = %w[pdf.haml haml html.haml]
    Ivars             = ::Object.instance_method(:instance_variables)
    IvarGet           = ::Object.instance_method(:instance_variable_get)
    IvarSet           = ::Object.instance_method(:instance_variable_set)
    KeepMethods = [
      :__class__,
      :__id__,
      :inspect,
      :initialize,
      :partial,
      :present,
      :instance_eval,
      :instance_exec,
      :extend,

      # additionally, haml needs the following (BAD! should use
      # Object.instance_method(name).bind(obj).call instead)
      :instance_variable_get,
      :instance_variable_set,
      :binding,
      :send,
      :is_a?,
    ]

    def self.silently
      old_verbose = $VERBOSE
      $VERBOSE    = nil
      yield
    ensure
      $VERBOSE    = old_verbose
    end

    def self.assimilate(target, *sources)
      setter = IvarSet.bind(target)
      sources.each do |source|
        Ivars.bind(source).call.each do |ivar|
          setter.call(ivar, IvarGet.bind(source).call(ivar))
        end
      end
    end

    def self.render(template, scope, locals, options)
      context     = new(scope, nil, options)
      temporary   = context.present(template, locals)
      content_for = IvarGet.bind(context).call(:@_panorama_content_for)

      temporary.gsub(content_for.regex) { |key|
        content_for[key]
      }
    end

    alias __class__ class
    silently do
      (instance_methods+private_instance_methods-KeepMethods).each do |name|
        undef_method name
      end
    end

    def initialize(scope, content_for, options)
      @_panorama_scope        = scope
      @_panorama_options      = options
      @_panorama_finder       = options[:template_finder] || Finder.new(options[:template_paths] || [], options[:suffixes] || StandardSuffixes)
      @_panorama_content_for  = content_for || ContentFor.new
      @_panorama_stack        = []
    end

    def partial(path, locals={})
      partial_path = _panorama_find_partial_path(path)
      Kernel.raise ArgumentError, "Could not find partial #{path.inspect}" unless partial_path

      _panorama_render_internal(Template.file(partial_path), locals)
    end

    def present(object, *args)
      if object.is_a?(Panorama::Template) then
        _panorama_render_internal(object, args.first)
      else
        Kernel.raise ArgumentError, "wrong number of arguments (#{args.size} for 3)" if args.size > 2
        locals  = args.last.is_a?(Hash) ? args.pop : {}
        file    = args.shift
        Kernel.raise "Not yet implemented"
      end
    end

    def content_for(name, *args, &block)
      @_panorama_content_for.add_content(name, capture_haml(&block)) # TODO: when going haml-independent, this needs to be refactored
      ""
    end

    def yielded(name, *args)
      @_panorama_content_for.add_yield(name, *args)
    end

  private
    def _panorama_find_partial_path(path)
      current_file  = @_panorama_stack.last && @_panorama_stack.last.file
      priority_dirs = [File.expand_path((current_file && File.dirname(current_file)) || Dir.getwd)]
      partial_path  = path.sub(%r{[^/]*\z}, '_\0') # add a _ in front of the filename

      @_panorama_finder.find(partial_path, priority_dirs) || @_panorama_finder.find(path, priority_dirs)
    end

    def _panorama_render_internal(template, locals)
      @_panorama_stack << template
      result = Haml::Engine.new(template.string).render(self, locals) { |*args, &block|
        yielded(*args, &block)
      }
      @_panorama_stack.pop
      result
    end

    def method_missing(name, *args, &block)
      if @_panorama_scope then
        @_panorama_scope.__send__(name, *args, &block)
      else
        super
      end
    end
  end
end
