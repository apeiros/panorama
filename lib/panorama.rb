# encoding: utf-8



require 'panorama/finder'
require 'panorama/template'
require 'panorama/version'



# Panorama
# Panorama provides a templating system, which allows the use of partials and content
# insertion from other places of a template.
module Panorama
  def self.find_template(name, directories, suffixes)
    Finder.new(directories, suffixes).find(name)
  end

  def self.render_template(path, locals={})
    Template.file(path).render(locals)
  end

  def self.render_presentation(object, *args)
  end
end
