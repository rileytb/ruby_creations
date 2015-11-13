require 'optparse'
require 'etc'
require 'fileutils'
require 'date'

@name_changer = '_filtered.'
@default_exts = [
  "jpg",
  "png",
  "gif"
]
@default_dirs = [
  "pictures",
  "documents",
  "desktop"
]

#-------------------#
# Get script params #
#-------------------#
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: filter.rb [where to filter]"
  opts.on("-d", "--dir [directory]", "Where to filter") do |d|
    options[:dir] = d
  end
end.parse!

# Set dir
@dir = options[:dir] || "pictures"

# return date in name
def get_time(name)
  m_date = File.stat(name).mtime.to_s
  time_array = m_date.split("-")
  year = time_array[0]
  month = time_array[1]
  return year, month
end

# move files to year directory
def move_files (file, year)
  new_loc = year.to_s + '/' + file

  if File.file?(new_loc)
    puts new_loc + " already existed - appending name changer..."
    name_array = file.split('.')
    name = name_array[0] + @name_changer + name_array[1]
    new_loc = year.to_s + '/' + name
  end

  result = FileUtils.mv file, new_loc, :verbose => true
end

# create year dir
def create_year_dir(year)
  #TODO - when creating, needs to have 1 January, 2 February, etc
  Dir.mkdir(year)
  Dir.chdir(year)
  i = 1
  while i <= 12 do
    Dir.mkdir(i.to_s + ' ' + Date::MONTHNAMES[i])
    i+=1
  end

  Dir.chdir(@dir)
end

def create_month_dir(year, month)
  Dir.chdir(year)
  Dir.mkdir(month + " " + Date::MONTHNAMES[month.to_i])
  Dir.chdir(@dir)
end

# ------------------------ #
# BEGIN #
# ------------------------ #
if @default_dirs.include? @dir.downcase
  @user = Etc.getlogin
  puts "Current user is: #{@user}... "
  @dir = "C:\\Users\\#{@user}\\#{@dir}"
end

puts "Preparing to filter: #{@dir} ..."
Dir.chdir(@dir)
Dir.foreach(@dir) do |file|
  name = file.split('.')
  ext = name[name.length - 1].downcase unless !name[1]
  if @default_exts.include? ext
    year, month = get_time(file)
    full_month = month + " " + Date::MONTHNAMES[month.to_i]

    if !Dir.exist?(year)
      puts year + " didn't exist. Creating directory..."
      create_year_dir(year)
    end

    if !Dir.exist?(year + '/' + full_month)
      puts year + '/' + full_month + "didn't exist. Creating directory... "
      create_month_dir(year, month)
    end

    report = move_files( file, year + '/' + full_month )
    puts file + " - move failed " unless report < 1
  end
end

puts "Done!"
