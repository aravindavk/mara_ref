require "http/server"
require "option_parser"

require "crinja"

build_output_dir = "output"
static_dir = "public"
templates_dir = "views"
port = 8080
build = false
dev = false

parser = OptionParser.new do |parser|
  parser.banner = "Usage: mara [subcommand] [arguments]"
  parser.on("build", "Build") do
    build = true
    parser.banner = "Usage: mara build [arguments]"
    parser.on("-o NAME", "--output-dir=NAME", "Output directory (Default: output)") { |od| build_output_dir = od.rstrip("/") }
    parser.on("-t NAME", "--templates-dir=NAME", "Templates directory (Default: views)") { |td| templates_dir = td.rstrip("/") }
    parser.on("-s NAME", "--static-dir=NAME", "Static directory (Default: static)") { |sd| static_dir = sd.rstrip("/") }
  end

  parser.on("dev", "Development Server") do
    dev = true
    parser.banner = "Usage: mara dev"
    parser.on("-p NUM", "--port=NUM", "Server Port (Default: 8080)") { |p| port = p.to_i }
    parser.on("-t NAME", "--templates-dir=NAME", "Templates directory (Default: views)") { |td| templates_dir = td.rstrip("/") }
    parser.on("-s NAME", "--static-dir=NAME", "Static directory (Default: static)") { |sd| static_dir = sd.rstrip("/") }
  end

  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
end

parser.parse

if dev
  env = Crinja.new
  env.loader = Crinja::Loader::FileSystemLoader.new(templates_dir)
  handlers = [HTTP::StaticFileHandler.new(static_dir, directory_listing: false)]

  server = HTTP::Server.new(handlers) do |context|
    filepath = "index.html.j2"
    if context.request.path != "/"
      filepath = "#{context.request.path.gsub(/^\//, "")}.html.j2"
    end
    template = env.get_template(filepath)
    context.response.content_type = "text/html"
    context.response.print template.render
  rescue Crinja::TemplateNotFoundError
    template = env.get_template("404.html.j2")
    context.response.status_code = 404
    context.response.content_type = "text/html"
    context.response.print template.render
  end

  puts "Listening on http://127.0.0.1:#{port}"
  server.listen(port)
end

def crawl(path)
  paths = [] of Path
  Dir.children(path).each do |entry|
    full_path = Path.new(path, entry)
    if File.directory?(full_path)
      if entry != "partials" && entry != "layouts"
        paths += crawl(full_path)
      end
    else
      paths << full_path
    end
  end
  paths
end

if build
  env = Crinja.new
  env.loader = Crinja::Loader::FileSystemLoader.new(templates_dir)

  outdir = Path.new(".", build_output_dir)
  paths = crawl("views")
  Dir.mkdir_p(build_output_dir)
  paths.each do |path|
    target_dir = File.dirname(path.to_s.gsub("#{templates_dir}/", "#{build_output_dir}/"))
    bname = File.basename(path).gsub(".html.j2", "")
    if bname != "index"
      target_dir = Path.new(target_dir, bname)
    end

    template = env.get_template(path.to_s.gsub("#{templates_dir}/", ""))
    Dir.mkdir_p(target_dir)
    target_file = Path.new(target_dir, "index.html")
    File.write(target_file, template.render)
    puts "#{path} => #{target_file}"
  end

  `cp -Rv #{static_dir}/* #{build_output_dir}/`
end
