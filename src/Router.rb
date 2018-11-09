
class Router

  def initialize()
    @paths = {}
  end

  def form_path(method, path, code)
    if @paths[method].nil?
      @paths[method] = {}
    end
    if Regexp == path.class
      if @paths[method]["REGEXP"].nil?
        @paths[method]["REGEXP"] = {}
      end
      @paths[method]["REGEXP"][path] = code
    else
      @paths[method][path] = code
    end
  end

  def doRoute(req, res)
    if @paths[req.method][req.rel_path].nil?
      if req.rel_path == "/favicon.ico"
        res.send_file(req.rel_path, req.abs_path)
      else
        curr = nil
        @paths[req.method]["REGEXP"].each do |regex, proc|
          if regex =~ req.rel_path
            curr = regex
          end
        end
        if curr != nil
          @paths[req.method]["REGEXP"][curr].call(req, res)
        else
          puts "This path has not been specified!".colorize(:red)
        end
      end
    else
      @paths[req.method][req.rel_path].call(req, res)
    end
  end

end
