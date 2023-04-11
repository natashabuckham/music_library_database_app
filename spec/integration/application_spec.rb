require "spec_helper"
require "rack/test"
require_relative "../../app"

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  def reset_artists_table
    seed_sql = File.read("spec/seeds/artists_seeds.sql")
    connection = PG.connect({ host: "127.0.0.1", dbname: "music_library_test" })
    connection.exec(seed_sql)
  end

  def reset_albums_table
    seed_sql = File.read("spec/seeds/albums_seeds.sql")
    connection = PG.connect({ host: "127.0.0.1", dbname: "music_library_test" })
    connection.exec(seed_sql)
  end

  before(:each) do
    reset_artists_table
    reset_albums_table
  end

  context "POST /" do
    it "adds a new album and returns 200 OK for /albums" do
      response =
        post("/albums", title: "Voyage", release_year: 2022, artist: 'ABBA')

        expect(response.status).to eq 302

        response = get("/albums")
        expect(response.body).to include 'Title: <a href="/albums/13">Voyage</a>'
    end

    it "returns 200 ok for /artists" do
      response = post("/artists", name: "Wild nothing", genre: "Indie")

      expect(response.status).to eq 302

      response = get("/artists")
      expect(response.body).to include 'Name: <a href="/artists/5">Wild nothing</a>'
    end
  end

  context "GET /" do
    it "returns 200 OK" do
      response = get("/artists")

      expect(response.status).to eq 200
      expect(response.body).to include 'Name: <a href="/artists/1">Pixies</a><br>'
    end
  end

  context "GET/albums/new" do
    it "returns the form page" do
      response = get('albums/new')

      expect(response.status).to eq 200
      expect(response.body).to include "<h1>Add an album</h1>"
      expect(response.body).to include '<form action="/albums" method="POST">'
      expect(response.body).to include '<input type="text" name="title">'
    end
  end

  context "GET /albums/:id" do
    it "returns HTML content for a single album" do
      response = get("/albums/1")

      expect(response.status).to eq 200
      expect(response.body).to include "<h1>Doolittle</h1>"
    end
  end

  context "GET /albums" do
    it "returns list of all albums in HTML" do
      response = get("/albums")

      expect(response.status).to eq 200
      expect(response.body).to include 'Title: <a href="/albums/1">Doolittle</a>'
      expect(response.body).to include "Released: 1989"
    end
  end

  context "GET /artists/:id" do
    it "returns HTML content for a single artist" do
      response = get("/artists/1")

      expect(response.status).to eq 200
      expect(response.body).to include "<h1>Pixies</h1>"
    end
  end

  context "GET /artists" do
    it "returns list of all artists in HTML" do
      response = get("/artists")

      expect(response.status).to eq 200
      expect(response.body).to include 'Name: <a href="/artists/1">Pixies</a>'
      expect(response.body).to include 'Name: <a href="/artists/2">ABBA</a>'
    end
  end
end
