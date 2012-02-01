# encoding: utf-8



require 'panorama'
require 'panorama/rendercontext'



module Panorama
  class RailsViewContext < RenderContext
    def initialize(controller, view_name)
      super
      RenderContext.assimilate(self, controller)
    end

    def render(options)
      partial = options[:partial]
      Kernel.raise ArgumentError, "Can only render :partial" unless partial
    end
  end
end

ActionController::Base.class_eval do
  def panorama_context(view_name)
    Panorama::RailsViewContext.new(view_context, view_name)
  end
end