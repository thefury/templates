REPOSITORYROOT="http://github.com/thefury/templates/raw/master/standard"

def commit(message)
  git :add => '.'
  git :commit => "-a -m '#{message}'"
end

def remote_file(filename, templatename)
  value = open(REPOSITORYROOT + templatename).read
  file filename, value
end


# ----------------------------------------
# Create the project
# ----------------------------------------
run "gem sources -a http://gems.github.com"
run "rm public/index.html"
remote_file ".gitignore", "dot_gitignore"

git :init
commit "Initial Commit"


# ----------------------------------------
# gems and cofig
# ----------------------------------------
gem("authlogic")
gem("rspec", :lib => false,  :version => ">=1.2.2")
gem("rspec-rails", :lib => false, :version => ">=1.2.2")
gem("webrat", :lib => false, :version => ">=0.4.3")
gem("cucumber", :lib => false, :version => ">=0.2.2")
gem("thoughtbot-factory_girl", :lib => "factory_girl")
gem("rcov", :lib => false)
gem("reek", :lib => false)
gem("roodi", :lib => false)
gem("jscruggs-metric_fu", :lib => false)
gem("haml")

rake "gems:install", :sudo => true
rake "gems:install"

# ----------------------------------------
# authlogic setup
# ----------------------------------------
generate(:session, "user_session")
generate(:controller, "user_sessions")

run "rm app/controllers/user_sessions_controller.rb"
remote_file "app/controllers/user_sessions_controller.rb", "user_sessions_controller.rb"
remote_file "app/views/user_sessions/new.html.erb", "user_sessions_new.html.erb"

run "rm -rf app/controllers/application_controller.rb"
remote_file "app/controllers/application_controller.rb", "application_controller.rb"

generate(:controller, "users")
generate(:model,
         "user",
         "login:string",
         "email:string",
         "crypted_password:string",
         "password_salt:string",
         "persistence_token:string",
         "single_access_token:string",
         "perishable_token:string",
         "login_count:integer",
         "failed_login_count:integer",
         "last_request_at:datetime",
         "current_login_at:datetime",
         "last_login_at:datetime",
         "current_login_ip:string",
         "last_login_ip:string")
run "rm app/models/user.rb"
remote_file "app/models/user.rb", "user.rb"

run "rm app/controllers/users_controller.rb"
remote_file "app/controllers/users_controller.rb", "users_controller.rb"

remote_file "app/views/users/_form.erb", "users_form.erb"
remote_file "app/views/users/edit.html.erb", "users_edit.html.erb"
remote_file "app/views/users/new.html.erb", "users_new.html.erb"
remote_file "app/views/users/show.html.erb", "users_show.html.erb"

rake "db:migrate"

route('map.resource :account, :controller => "users"')
route('map.resources :users')
route('map.resource :user_session')
route('map.login "/login", :controller => "user_sessions", :action => "new"')
route('map.logout "/logout", :controller => "user_sessions", :action => "destroy"')
route('map.register "/register", :controller => "users", :action => "new"')
commit "AuthLogic added and configured initial routes"

# ----------------------------------------
# CSS and common images
# ----------------------------------------
remote_file "public/stylesheets/ie.css", "ie.css"
remote_file "public/stylesheets/print.css", "print.css"
remote_file "public/stylesheets/screen.css", "screen.css"
remote_file "public/stylesheets/site.css", "site.css"

commit "Added blueprint stylesheets"

# ----------------------------------------
# haml setup
# ----------------------------------------
# there is none now.

# ----------------------------------------
# cucmber setup
# ----------------------------------------
generate :rspec
generate :cucumber
run "touch features/factories.rb"

commit "Added rspec and cucumber"

# ----------------------------------------
# test helpers setup
# ----------------------------------------
run "rm test/test_helper.rb"
remote_file "test/test_helper.rb", "test_helper.rb"

commit "Custom helpers added and configured"

# ----------------------------------------
# metrics setup
# ----------------------------------------
rakefile "metric_fu.rake" do
  <<-TASK
begin
  require 'metric_fu'
rescue LoadError
end
  TASK
end

rakefile "rcov.rake", open(REPOSITORYROOT + "rcov_task.rake").read

commit "extra rake tasks added"

# ----------------------------------------
# Custom Pages
# ----------------------------------------
generate(:controller, "site")

# copy over my own goodies
remote_file("app/controllers/site_controller.rb", "site_controller.rb")
remote_file("app/views/layouts/site.html.haml", "layout_site.html.haml")
run 'echo "You can find me in app/views/site/index.html.haml" > app/views/site/index.html.haml'
remote_file("app/views/site/privacy.html.haml", "privacy.html.haml")
remote_file("app/views/site/terms.html.haml", "terms.html.haml")


route('map.root :controller => "site", :action => "index"')
route('map.privacy "/privacy", :controller => "site", :action => "privacy"')
route('map.terms "/terms", :controller => "site", :action => "terms"')

commit "Added main site controller"
