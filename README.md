# Majin
To run, use `ruby server.rb`. For help, use `ruby server.rb -h`. Please note that a firewall will most definitely get in the way so try to use 'localhost' if possible.
## Ruby Server
Majin is a lightweight HTTP server built using the core Ruby library.

# Properties
Majin, as an HTTP server takes advantage of 4 main properties:
- Modular
- Multithreaded
- Configurable
- Easy To Use

## Modular
Everyone loves solid modularity when it comes to development. This server aims to achieve this by placing everything into its own class. The Server class uses Request and Response classes to facilitate the 'conversation' with the client connection, as well as a Router class to specify actions based on certain request lines. This is all done by following the [Composition over Inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance) design pattern that so many people prefer these days. It forces each class to interface with each other and therefore allows for polymorphism. It is also easier to code for myself as I do not have to worry about confusing each class's responsibility.

## Multithreaded
Since there will be a lot of repeated code being ran, using multiple threads would make sense. This would allow for an increase in performance. This works by spawning a new thread once the server accepts a connection. By doing this, the server is free to wait and listen. MRI, which is what is used here, has a Global Interpreter Lock in place. This prevents true multithreading from taking place. The GIL simulates a process scheduler used by CPUs and allots execution time for each Ruby thread. This lets the interpreter clean up race conditions with shared memory. Right now as it stands, I believe that there is no concurrency issues when reading and writing simultaneously.

Next step in this area I believe would be to switch over to multiprocessing. This will bypass the GIL that prevents any true concurrency and will allow for a huge speed bonus. The main problem though, would be that a ton of potential issues arise when multiple processes are used. Race conditions become a big problem and there is always a problem with a denial of service attack. These attacks occur by spamming requests to a server with the intention to blow the stack with too many threads or processes. I believe that a semi-challenging solution would be to use a single write, multiple read Mutex. I wonder if these can work between processes as well as threads. More research is needed for this.

## Configurable
To maximize usefulness, the server was built with configuration in mind. The most shallow level of configuration is the `CONFIG.rb` file found in the root directory. This holds the constant values that the server uses. Defaults such as host, port, log files, and error files can be set, in addition to expanding the response codes and MIME-types accepted.
### Options
When the server is initialized, it takes in a dictionary of parameters. These are used to change the default values, as well as to set certain flags. Here is an example of how to use these options:
```Ruby
options = {
  timer: true, # sets flag to measure and display performance measures
  ssl: true, # tells server to look for crt and key files to use HTTPS
  crt: "/path/ssl/certificate.crt", # both of these files are
  key: "/path/ssl/key_file.key", # needed to verify the SSL certificate
  host: '0.0.0.0',
  port: 12345
}

server = Server.new options
```
### Routes
The next level of configuration is done after the server is instantiated. The developer can use paths and methods to specify the action to be taken. For example:
```ruby
server.get "/" do |req, res|
  res.send(req.method, req.abs_path)
end

server.get %r"\/[a-zA-Z1-9\-\/_]*[\.]?[a-z]*" do |req, res|
  puts "In the block"
  res.send(req.method, req.abs_path)
end

server.post "/" do |req, res|
  data = JSON.parse(req.body)
  puts data['student']
  res.send(req.method, req.abs_path)
end  
```
The server has a function for each HTTP method. The parameters taken in by these functions are a route followed by a block of code. A route can either be a string literal or a Regexp class. Using regular expressions, the server will match any request path if no literals are defined a priori. This allows for the developer to be general as needed, or specific when necessary. As of right now, the Regexp should be ordered by least specific to most specific in a top down manner. To fix this, a 'correctness of match' will be added inside the server logic.
The block receives a request and a response object. These are used to access and relevant information that may be needed. Inside the block resides the code that the developer wishes to run given a certain method and route. This allows for a basic API to quickly be built. From the `CONFIG.rb` file, certain methods are flagged to have a body. The included JSON module can be used to parse the body and act accordingly.
### Custom Response
The response class is a fancy wrapper that provides methods to facilitate responding to the client. There is a send_file(method, path) function that will send a file at the given path using the specified method. Additionally, if a user wanted to just send a string using proper HTTP format, then a send_string(method, string) function is provided. The raw, bare bones method provided is puts, which is a wrapper to output directly to the socket with no format specified.
