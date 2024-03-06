enable :sessions
set :session_secret, 'fa5BBHS41ZAdUTQ4R4zk48fZxxz66XkfxutJ4hA3Irn3QiBURqsdJ0110hIIQ5Gt'
# TODO: Don't use hardcoded encryption key in production

permissions = {
  'user' => 0,
  'creator' => 1,
  'admin' => 2
}

def all_of(*paths)
  /(#{paths.join('|')})/
end

def show_error(desc, url)
  session[:error] = desc
  session[:url] = url
  redirect('/error')
end

# Middleware to check permissions
before do
  path = request.path_info
  admin_pattern = '\/admin'
  public_pattern = '\/(login|signup|error)'

  p path

  return if path.match(public_pattern) || path == '/'

  id = session[:id]
  user = get_user(id)

  show_error('You have to be logged in to see this content...', '/login') if user.nil?

  if path.match(admin_pattern)
    return if user['permissions'] == permissions['admin']

    show_error('You are not allowed to view this page...', '/play')
  end
end
