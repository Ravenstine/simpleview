Simpleview
-------------
A simple browser-based remote desktop application using Ruby, EventMachine, and WebSocket.

#### Installation
Currently, you must be using Linux with **x11-apps** and **imagemagick**  installed.  However, there isn't anything to prevent Simpleview from working on a Mac except a compatible command needs to be added to capture the screen.

If you are using Debian, run the following:

```sudo apt-get -y install x11-apps imagemagick```

```bundle install```

#### Usage
Run the server:
```ruby server.rb```

Then visit the client page to make sure the server is working at ***http://localhost:5353/client.html***.

Note that you must have port 5353 unblocked in order to access the server remotely.

#### TODO
Only left mouse clicks are supported at the moment.  No keystrokes are supported yet, but I'll be working on this.
