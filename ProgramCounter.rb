class LocalFile
  attr_reader :name
  def initialize(name)
    @name = name
  end
  def row
    File.open(@name, 'r'){|f|
      while f.gets; end;
      f.lineno
    }
  end
  def extension
    m = @name.match(/\.([^\.]+)$/)
    m[1]
  end
end
class Files
  # filter_pathes e.q. 'dir1/dir2'
  def initialize(root_path, filter_paths=['**'], extension='*')
    @filter_paths = filter_paths
    @extension = extension
    @files = []
    filter_paths.each do |filter_path|
      @files << Dir.glob("#{root_path}/**/#{filter_path}/**/*.#{extension}").map{|name| LocalFile.new(name) }
    end
    @files.flatten!
  end
  def count; @files.size end;
  def rows; @files.map(&:row).inject(:+) end;
  def to_s; "#{@extension}, #{count}, #{rows}" end;
  def extensions
    ex_ary = @files.inject([]){|a, i| a << i.extension}.inject(Hash.new(0)){|h, i| h[i] += 1; h}.sort{|(k1,v1), (k2,v2)| v2 <=> v1}
    sum = ex_ary.each.inject(0){|sum, pair| sum += pair[1]}
    ex_ary.map{|k, v| "#{k} #{v} (#{100*v/sum}%)"}
  end
end

def extension_percent(root_path, filter_paths=['**'])
  puts "** analyze in (#{root_path}) filter by (#{filter_paths} **"
  puts " -- extension, number of files, percent in amount --"
  Files.new(root_path, filter_paths).extensions.each{|e| puts "    #{e}"}
end
def extension_count(root_path, filter_paths=['**'], *extensions)
  puts "** analyze in (#{root_path}) filter by (#{filter_paths} **"
  puts " -- extension, number of files, percent in amount --"
  extensions.each do |extension|
    puts "    #{Files.new(root_path, filter_paths, extension).to_s}"
  end
end

# ======== Edit following =========
root_path1 = '/Users/username/java_dir'
filter_paths1 = ['src/main/java', 'src/main/resources', 'src/main/config']
extension_percent(root_path1, filter_paths1)
root_path2 = '/Users/username/rails_dir'
filter_paths2 = ['app']
extension_percent(root_path2, filter_paths2)

extension_count(root_path1, filter_paths1,'java', 'xml')
extension_count(root_path2, filter_paths2,'rb', 'erb', 'slim', 'coffee', 'js')

