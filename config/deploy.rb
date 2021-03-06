set :application, "docs.puppetlabs.com"
set :repository, "git://github.com/puppetlabs/puppet-docs.git"

task :primary do
    set :user,      "deploy"
    set :domain,    "#{user}@docs.puppetlabs.com"
    set :deploy_to, "/var/www/#{application}"
end

task :mirror do
    set :user,      "deploy"
    set :domain,    "#{user}@docs.mirror1.puppetlabs.com"
    set :deploy_to, "/srv/www/docs.mirror1.puppetlabs.com/html"
end

namespace :vlad do

  desc "Build the documentation site"
  remote_task :build do
    sh "git checkout -b release"
    Rake::Task['generate'].invoke
    Rake::Task['tarball'].invoke
    sh "git add -f output puppetdocs-latest.tar.gz"
    sh "git commit -a -m 'Release dated #{Time.now}'"
    sh "git push --force origin release"
    sh "git checkout master"
    sh "git branch -D release"
  end

  desc "Release the documentation site"
  remote_task :release do
    repo = "#{deploy_to}/repo"
    run "rm -fr #{repo}; mkdir -p #{repo}"
    run "git clone #{repository} #{repo}"
    run "cd #{repo} && git pull origin release"
    run "cd #{repo} && git checkout release"
    run "cd #{repo} && cp puppetdocs-latest.tar.gz #{deploy_to}"
    run "cd #{repo}/output && cp -R * #{deploy_to}"
    run "rm -fr #{repo}"
  end

  desc "Build and release the documentation site"
  task :deploy => ['vlad:build', 'vlad:release']
end
