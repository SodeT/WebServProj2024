# The BIG Casino

require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'


require_relative 'internal/model'
include Model
require_relative 'internal/utils'
require_relative 'internal/public'
require_relative 'internal/user'

require_relative 'internal/admin/dashboard'
require_relative 'internal/admin/boosters'
require_relative 'internal/admin/cards'
require_relative 'internal/admin/events'
require_relative 'internal/admin/prices'
