namespace :gem do
  desc "Builds the gem and puts it into the 'build' directory."
  task :build do
    sh 'gem build *.gemspec'
    mkdir 'build' unless File.directory?('build')
    sh 'mv *.gem build'
  end

  desc "Clobbers, then rebuilds and installs the gem"
  task :install => [:clobber, :build] do
    sh 'gem install -l ./build/*.gem'
  end

  desc "Removes all built gems from the 'build' directory."
  task :clobber do
    sh 'rm build/*.gem'
  end
end
