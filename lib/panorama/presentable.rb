# encoding: utf-8



require 'panorama/rendercontext'



module Panorama
  module Presentable
    def render(*args, &block)
      Panorama::Presentation.new(self).render(*args, &block)
    end
  end
end
