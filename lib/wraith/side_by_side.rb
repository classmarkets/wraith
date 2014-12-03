require 'wraith'
require 'image_size'
require 'open3'
require 'parallel'
require 'pp'

class Wraith::SideBySideImages
  attr_reader :wraith

  def initialize(config)
    @wraith = Wraith::Wraith.new(config)
  end

  def generate_side_by_side_images
    files = Dir.glob("#{wraith.directory}/*/*.png").sort.reject { |f| f.match /_(diff|sbs).png$/ }

    Parallel.each(files.each_slice(2), in_processes: Parallel.processor_count) do |base, compare|
      sbs = base.gsub(/([a-z0-9]+).png$/, 'sbs.png')
      compose_task(base, compare, sbs)
    end
  end

  def compose_task(base, compare, output)
    cmdline = "montage #{base} #{compare} -tile 2x1 -geometry +1+0 -background black #{output}"
    Open3.popen3(cmdline) { |_stdin, _stdout, stderr, _wait_thr| stderr.read }
  end
end
