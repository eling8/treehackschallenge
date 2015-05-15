require 'sinatra'
require 'twilio-ruby'
require 'sinatra/activerecord'
require './config/environments' #database configuration
require './models/person'
require 'haml'
require 'sinatra/flash'

enable :sessions
use Rack::MethodOverride

# A hack around multiple routes in Sinatra
def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

# Home page and reference
get '/' do
  haml :home
end

get_or_post '/addnumber' do
  e = Person.new
  e.name = params[:name]
  e.number = params[:number]
  if e.save
    flash[:success] = "Added entry successfully."
    redirect '/'
  else
    flash[:error] = "Error. Check that name is not empty and number contains exactly ten digits."
    redirect '/'
  end
end

# Send SMS
post '/sendsms' do
  # account_sid = "AC3441ffbb10cf4fd9ada0aaeed8505e99"
  # auth_token  = "47b773f061c61a6bd35a70f82b4bb1cc"
  account_sid = ENV['ACCOUNT_SID']
  auth_token = ENV['AUTH_TOKEN']
  @client = Twilio::REST::Client.new account_sid, auth_token
  
  # @client = Twilio::REST::Client.new ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN']

  @people = Person.all
  @people.each do |p|
    @client.account.messages.create(:body => params['smsBody'], :to => "+1" + p.number, :from => "+14154888950")
  end

  flash[:success] = "Message sent to all numbers."

  redirect '/'
end

# Send MMS
post '/sendmms' do
  #account_sid = "AC3441ffbb10cf4fd9ada0aaeed8505e99"
  #auth_token  = "47b773f061c61a6bd35a70f82b4bb1cc"
  account_sid = ENV['ACCOUNT_SID']
  auth_token = ENV['AUTH_TOKEN']
  # @client = Twilio::REST::Client.new ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN']
  @client = Twilio::REST::Client.new account_sid, auth_token

  @people = Person.all
  @people.each do |p|
    @client.account.messages.create(
      :body => params['mmsBody'], 
      :to => "+1" + p.number, 
      :from => "+14154888950", 
      :media_url => params['mmsURL'])
  end

  flash[:success] = "Message sent to all numbers."

  redirect '/'
end

get '/numbers' do
  @people = Person.all
  haml :numbers
end

get_or_post '/delete' do
  p = Person.where(id: params[:id]).first
  p.destroy
  redirect '/numbers'
end
