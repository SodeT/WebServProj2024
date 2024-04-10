enable :sessions
set :session_secret, 'fa5BBHS41ZAdUTQ4R4zk48fZxxz66XkfxutJ4hA3Irn3QiBURqsdJ0110hIIQ5Gt'
# TODO: Don't use hardcoded encryption key in production

permissions = {
  'user' => 0,
  'creator' => 1,
  'admin' => 2
}

# An internal helper function that globbs paths together separated by '|'
# @param paths [Array] an array of paths
# @return [String] a string of every path separated by a '|'
def all_of(*paths)
  /(#{paths.join('|')})/
end

# A helper function that sets some error related session tokens and redirects the user to the error page
# @param desc [String] a description of the error
# @param url [String] the url that will lead the user back on track
def show_error(desc, url)
  session[:error] = desc
  session[:url] = url
  redirect('/error')
end

# Middleware to check permissions
before do
  path = request.path_info
  admin_pattern = '\/admin'
  public_pattern = '\/(login|signup|fakespin|error)'

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
