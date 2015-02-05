require 'rack'
require 'rack/stream'

class App
  include Rack::Stream::DSL

  stream do
    after_open do
      count = 0
      @timer = EM.add_periodic_timer(1) do
        chunk "chunky monkey\n"
      end
    end

    before_close do
      @timer.cancel
    end

    [200, {'Content-Type' => 'text/plain'}, ['Hello']]
  end
end

app = Rack::Builder.app do
  use Rack::Stream
  run App.new
end

# run app


Rack::Server.start({
  app: app,
  server: 'thin',
  Host:   '0.0.0.0',
  Port:   '3000'
})