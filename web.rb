require 'sinatra/base'
require 'open-uri'
require 'net/http'

class Web < Sinatra::Base
  def fetch_gem_downloads(gem_name:)
    JSON(Net::HTTP.get_response(URI("https://rubygems.org/api/v1/gems/#{gem_name}.json")).body)['downloads']
  end

  def number_with_delimiter(number:)
    number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def fetch_badge(gem_downloads:)
    URI.parse("https://raster.shields.io/badge/gem%20downloads-#{gem_downloads}-4bc425.png").open.read
  end

  def fetch_owner_downloads(owner:)
    JSON(Net::HTTP.get_response(URI("https://rubygems.org/api/v1/owners/#{owner}/gems.json")).body).sum do |gem|
      gem['downloads']
    end
  end

  before do
    content_type 'image/png'
    headers['Content-Disposition'] = 'inline; filename="remote-file.png"'
  end

  get '/gems/:gem_name.png' do
    gem_name = params.fetch('gem_name')

    gem_downloads = number_with_delimiter(number: fetch_gem_downloads(gem_name: gem_name))

    fetch_badge(gem_downloads: gem_downloads)
  end

  get '/owners/:owner.png' do
    owner = params.fetch('owner')

    gem_downloads = number_with_delimiter(number: fetch_owner_downloads(owner: owner))

    fetch_badge(gem_downloads: gem_downloads)
  end
end