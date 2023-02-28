require 'sinatra'
require 'uri'
require 'net/http'

def fetch_gem_downloads(gem_name:)
  JSON(Net::HTTP.get_response(URI("https://rubygems.org/api/v1/gems/#{gem_name}.json")).body)['downloads']
end

def number_with_delimiter(number:)
  number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

def fetch_badge(gem_downloads:)
  Net::HTTP.get_response(URI("https://img.shields.io/badge/gem%20downloads-#{gem_downloads}-green")).body
end

get '/:gem_name' do
  gem_name = params.fetch('gem_name')

  gem_downloads = number_with_delimiter(number: fetch_gem_downloads(gem_name: gem_name))

  fetch_badge(gem_downloads: gem_downloads)
end
