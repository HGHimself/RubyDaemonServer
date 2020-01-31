class Templator

  def initialize
    @templates = {}
  end

  class TemplateError < StandardError
  end

  def read(path)
    raise IOError, "No file with that name!" if !File.exist?(path) || File.directory?(path)

    File.open(path, "rb") do |file|
      return parse file.read, 0
    end
  end

  def parse(text, i)
    puts "#{i} -- parsing #{text}"
    text.gsub!(/~{[^}]*}~/) do |elem|
      parse buildElement(elem), i + 1
    end
    return text
  end

  def buildElement(elem)
    if match = elem.match(/(\w+)/)
      name = match.to_s
      options = {}
      elem.scan(/(\w+)\s*=\s*["']([^'"]+)["']/).each do |match|
        options[match[0]] = match[1]
      end

      raise TemplateError, "#{name} has not been initilaized" if @templates[name].nil?

      return @templates[name].call(options)
    else
      return elem
    end
  end

  def prime(name, &code)
    @templates[name] = code;
  end
end

t = Templator.new()

t.prime("Templator") do |options|
  if options['stop']
    "all good here boys!!"
  else
    "~{Templator id=\"identifier\" class=\"some class id\" stop='yes please'}~"
  end
end

t.prime("Nav") do |options|
<<NAV
  <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-2">
    <a class="navbar-brand" href="/">Home</a>
    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavAltMarkup" aria-controls="navbarNavAltMarkup" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNavAltMarkup">
      <div class="navbar-nav">
        <a class="nav-item nav-link active" href="/">Home <span class="sr-only">(current)</span></a>
        <a class="nav-item nav-link" href="/animation">Sorter</a>
        <a class="nav-item nav-link" href="/encryption">Encryptor</a>
        <a class="nav-item nav-link" href="/performance">Server Performance</a>
        <a class="nav-item nav-link" href="/color">Colors</a>
        <a class="nav-item nav-link float-right" href="https://github.com/HGHimself/" target="_blank">Github</a>
      </div>
    </div>
  </nav>
NAV
end
