require 'optparse'
require 'etc'
require 'fileutils'
require 'date'
require 'exifr'

@log_file = File.new("filter_log.txt", "a")
@log_file.puts "------------------------------------------"
@default_exts = {
  pictures: [
  "jpg",
  "png",
  "gif"
  ],
  videos: [
    "mov",
    "mp4",
    "mts",
    "3gp"
  ]}
@default_dirs = [
  "pictures",
  "videos"
]

#-------------------#
# Get script params #
#-------------------#
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: filter.rb -d [where to filter]"
  # Directory to filter
  opts.on("-d", "--dir [directory]", "Where to filter") do |d|
    options[:dir] = d
  end
  # Full year directory creation
  opts.on("-f", "--fulldir", "Add all month folders when year directory is created") do |f|
    options[:full_dir] = f
  end
  # Text for dupes
  opts.on("-a", "--append [text]", "Text to append to duplicate items; defaults to _filtered") do |a|
    options[:append] = a
  end
  # use Modified (over date taken on JPGs)
  opts.on("-m", "--modified", "Use the 'modified' field for JPGs instead of Date Taken") do |m|
    options[:modified] = m
  end
end.parse!

@dir = options[:dir] || "pictures"
@full_dir = options[:full_dir] || false
@name_appendage = options[:append] || "_filtered"
@modified = options[:modified] || false

# ------------- #
# Functions
# ------------- #

# ----------------------------------
# return date in name
# ----------------------------------
def get_modified_date(name)
  m_date = File.stat(name).mtime.to_s
  time_array = m_date.split("-") unless !m_date
  return false, false unless time_array.length > 1
  return time_array[0], time_array[1]
end

# ----------------------------------
# gets JPEG date taken
# ----------------------------------
def get_taken_date(name)
  data = EXIFR::JPEG.new(name)
  date_taken = data.date_time_original
  temp = date_taken.to_s.split(' ')
  date = temp[0].split('-')
  return date[0], date[1]
end

# ----------------------------------
# move files to year directory
# ----------------------------------
def move_files (file, location)
  new_loc = location.to_s + '/' + file

  if File.file?(new_loc)
    @log_file.puts new_loc + " already existed - appending name changer..."
    name_array = file.split('.')
    name = name_array[0] + @name_appendage + "." + name_array[1]
    new_loc = location.to_s + '/' + name
  end

  result = FileUtils.mv file, new_loc
  return result, new_loc
end

# ----------------------------------
# create year dir
# ----------------------------------
def create_year_dir(year)
  Dir.mkdir(year)

  # allows unneeded month folders to be an option
  if @full_dir then
    @log_file.puts "Creating ALL months in #{year} directory"
    i = 1
    while i <= 12 do
      Dir.mkdir(year + "/" + i.to_s + ' ' + Date::MONTHNAMES[i])
      i += 1
    end
  end
end

# ----------------------------------
# Just creates the month dir: # NAME
# ----------------------------------
def create_month_dir(year, month)
  Dir.mkdir(year + "/" + month + " " + Date::MONTHNAMES[month.to_i])
end

# ------------------------ #
# BEGIN SCRIPT#
# ------------------------ #
# If passed one of the filterable libraries,
# find the username to change to that dir
if @default_dirs.include? @dir.downcase
  @default_exts = @default_exts[@default_dirs.downcase]
  @user = Etc.getlogin
  @dir = "C:\\Users\\#{@user}\\#{@dir}"
end

puts "Preparing to filter: #{@dir}"
puts "Do you want to continue? (y/n)"
input = gets.chomp

#  Doing it this way so everything but positive exits
if input.downcase != "y" && input.downcase != "yes"
  puts "Exiting..."
  exit
end

@log_file.puts "Script beginning at: #{Time.now.strftime("%d/%m/%Y %H:%M")}"
@log_file.puts "Filtering on #{@dir}"
@log_file.puts "Current user is: #{@user}... "

Dir.chdir(@dir)
Dir.foreach(@dir) do |file|
  name = file.split('.')
  ext = name[name.length - 1].downcase unless !name[1]
  if @default_exts.include? ext
    if (ext == "jpg" && !@modified)
      year, month = get_taken_date(file)
    else
      year, month = get_modified_date(file)
    end

    full_month = month + " " + Date::MONTHNAMES[month.to_i]
    full_path = year + '/' + full_month

    if !Dir.exist?(year)
      @log_file.puts year + " didn't exist. Creating year directory..."
      create_year_dir(year)
    end

    if !Dir.exist?(full_path)
      @log_file.puts full_path + " didn't exist. Creating month directory... "
      create_month_dir(year, month)
    end

    report, new_loc = move_files(file, full_path)

    if report > 0
      @log_file.puts("Moving #{file} to #{new_loc} - move failed!!!")
    else
      @log_file.puts("Moving #{file} to #{new_loc}")
    end
  end
end

puts "Done!"
@log_file.puts "Success!"
@log_file.close
