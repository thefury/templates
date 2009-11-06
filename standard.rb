REPOSITORYROOT="http://github.com/thefury/templates/raw/master/"

def commit(message)
  git :add => '.'
  git :commit => "-a -m '#{message}'"
end

def remote_file(filename, templatename)
  value = open(REPOSITORYROOT + templatename).read
  file filename, value
end


# Create the project
run "gem sources -a http://gems.github.com"
run "rm public/index.html"
remote_file ".gitignore", "dot_gitignore"

git :init
commit "Initial Commit"



# gems and cofig
gem("authlogic")
rake "gems:install", :sudo => true

# authlogic setup
# user_sessions
generate(:session, "user_session")
generate(:controller, "user_sessions")
run "rm app/controllers/user_sessions_controller.rb"
file "app/controllers/user_sessions_controller.rb", <<-SESSION
class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end
end
SESSION

file "app/views/user_sessions/new.html.erb", <<-END
<h1>Login</h1>

<% form_for @user_session, :url => user_session_path do |f| %>
  <%= f.error_messages %>
  <%= f.label :login %><br />
  <%= f.text_field :login %><br />
  <br />
  <%= f.label :password %><br />
  <%= f.password_field :password %><br />
  <br />
  <%= f.check_box :remember_me %><%= f.label :remember_me %><br />
  <br />
  <%= f.submit "Login" %>
<% end %>
END
route('map.resource :user_session')
route('map.root :controller => "user_sessions", :action => "new"')

# rewrite the Application controller
run "rm -rf app/controllers/application_controller.rb"
file "app/controllers/application_controller.rb", <<-END
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def require_user
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
END

# users
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
file "app/models/user.rb", <<-USER
class User < ActiveRecord::Base
  acts_as_authentic
end
USER

generate(:controller, "users")
route('map.resource :account, :controller => "users"')
route('map.resources :users')

run "rm app/controllers/users_controller.rb"
file "app/controllers/users_controller.rb", <<-END
class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
END

file "app/views/users/_form.erb", <<-END
<%= form.label :login %><br />
<%= form.text_field :login %><br />
<br />
<%= form.label :email %><br />
<%= form.text_field :email %><br />
<br />
<%= form.label :password, form.object.new_record? ? nil : "Change password" %><br />
<%= form.password_field :password %><br />
<br />
<%= form.label :password_confirmation %><br />
<%= form.password_field :password_confirmation %><br />
END

file "app/views/users/edit.html.erb", <<-END
<h1>Edit My Account</h1>

<% form_for @user, :url => account_path do |f| %>
  <%= f.error_messages %>
  <%= render :partial => "form", :object => f %>
  <%= f.submit "Update" %>
<% end %>

<br /><%= link_to "My Profile", account_path %>
END

file "app/views/users/new.html.erb", <<-END
<h1>Register</h1>

<% form_for @user, :url => account_path do |f| %>
  <%= f.error_messages %>
  <%= render :partial => "form", :object => f %>
  <%= f.submit "Register" %>
<% end %>
END

file "app/views/users/show.html.erb", <<-END
<p>
  <b>Login:</b>
  <%=h @user.login %>
</p>

<p>
  <b>Login count:</b>
  <%=h @user.login_count %>
</p>

<p>
  <b>Last request at:</b>
  <%=h @user.last_request_at %>
</p>

<p>
  <b>Last login at:</b>
  <%=h @user.last_login_at %>
</p>

<p>
  <b>Current login at:</b>
  <%=h @user.current_login_at %>
</p>

<p>
  <b>Last login ip:</b>
  <%=h @user.last_login_ip %>
</p>

<p>
  <b>Current login ip:</b>
  <%=h @user.current_login_ip %>
</p>


<%= link_to 'Edit', edit_account_path %>
END


rake "db:migrate"
commit "AuthLogic added and configured"


# fill in the acts_as_authentic into user model
#fill in the correct controller code
#fill in the views for the user views
# map the resources

# fill in the application controller functions

# user registration routes

# fill in the users functions
# fill in the users views

# all automatic tests I want to add for this

# commit




# haml setup

# cucmber setup

# test helpers setup

# coverage setup
