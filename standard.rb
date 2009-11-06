REPOSITORYROOT="http://github.com/thefury/templates/raw/master/"

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
rake "gems:install", :sudo => true


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
route('map.root :controller => "user_sessions", :action => "new"')

commit "AuthLogic added and configured"

# ----------------------------------------
# CSS and common images
# ----------------------------------------

# ----------------------------------------
# haml setup
# ----------------------------------------

# ----------------------------------------
# cucmber setup
# ----------------------------------------

# ----------------------------------------
# test helpers setup
# ----------------------------------------
rm "rm test/test_helper.rb"
file "test/test_helper.rb", "test_helper.rb"

commit "Custom helpers added and configured"

# ----------------------------------------
# coverage setup
# ----------------------------------------
