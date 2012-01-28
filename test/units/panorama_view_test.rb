require_relative '../helper.rb'

class TestView < Test::Unit::TestCase
  def test_all
    assert_equal(
      File.read($data+'test1/result.html'),
      p(Panorama::Template.file($data+'test1/outer.html.haml').render)
    )
  end
end