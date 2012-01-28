# encoding: utf-8



require 'panorama/rendercontext'



module Panorama
  module Presentable
    def render(*args)
      Panorama::RenderContext.present(*args)
    end
  end
end
