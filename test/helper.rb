## HOW TO RUN THE TESTS
# ruby -r ./test/helper.rb test/units/panorama_view_test.rb



## Add the lib dir to $LOAD_PATH
lib_dir = File.expand_path('../../lib', __FILE__)
if File.directory?(lib_dir) then
  $LOAD_PATH.unshift lib_dir
else
  puts "WARNING",
       "Could not find the lib dir.",
       "Tests may not run for the expected version of the library, or even not at all."
end



## requires
require 'pathname'
require 'test/unit'
require 'panorama'



## prepare global data
$data = Pathname('../data').expand_path(__FILE__)
