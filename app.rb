# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  post '/albums' do # add a new album
    if invalid_request_parameters?
      status 400
      return ''
    end

    repo = AlbumRepository.new
    artist_repo = ArtistRepository.new
    @album = Album.new
    @album.title = params[:title]
    @album.release_year = params[:release_year]
    @album.artist_id = artist_repo.find_id_by_name(params[:artist])

    repo.create(@album)

    redirect '/albums'
  end

  get '/albums/new' do # add new album form
    erb(:add_album)
  end

  get '/albums/:id' do # show an individual album
    id = params[:id]
    album_repo = AlbumRepository.new
    album = album_repo.find(id)

    @title = album.title
    @release_year = album.release_year
    artist_id = album.artist_id

    artist_repo = ArtistRepository.new
    artist = artist_repo.find(artist_id)
    @artist_name = artist.name

    response = erb(:album)
    return response
  end

  get '/albums' do # show all albums
    repo = AlbumRepository.new
    @albums = repo.all

    response = erb(:albums)
    return response
  end

  get '/artists/new' do # add new artist form
    erb(:add_artist)
  end

  get '/artists/:id' do # show an individual artist
    id = params[:id]
    artist_repo = ArtistRepository.new
    artist = artist_repo.find(id)

    @name = artist.name
    @genre = artist.genre

    return erb(:artist)
  end

  get '/artists' do # show all artists
    repo = ArtistRepository.new
    @artists = repo.all

    return erb(:artists)
  end

  post '/artists' do # add a new artist
    repo = ArtistRepository.new
    new_artist = Artist.new

    new_artist.name = params[:name]
    new_artist.genre = params[:genre]

    repo.create(new_artist)

    redirect '/artists'
  end

  def invalid_request_parameters?
    path = request.path_info

    case path
      when '/artists'
        return true if params[:name] == nil || params[:genre] == nil
        return true if params[:name] == "" || params[:genre] == ""
        return false

      when '/albums'
        return true if params[:title] == nil || params[:release_year] == nil || params[:artist] == nil
        return true if params[:title] == "" || params[:release_year] == "" || params[:artist] == ""
        return false
    end
  end
end
