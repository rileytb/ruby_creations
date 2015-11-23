# ruby_creations
Tasks written in ruby

This 'filter' script is intended to move media (only pictures for now) into the file structure that I use for my media. This saves time when copying from a storage device, and allows for consistent media storage.

File Structure Example:
    Pictures Library > 2015 > 01 January

How it works:

This script will look through the specified directory for any file types that match the photo defaults: .jpg, .png, and .gif (this will be eventually available for modification)

Any that are of those types then have their Modified Date checked, and
  1. Output the directory that will be filtered and ask the user for confirmation (aborts if n/no)
  2. Check that the Year directory (i.e. 2015) exists
    a. If the year directory doesn't exist, create the Year directory with all month directories (01 January - 12 December), then move the picture
    b. If the Year directory exists, and the Month directory (i.e. 06 June) doesn't, it will be created, then move the picture
    c. If the Year directory exists, and the Month directory exists, and the picture name is already used, append _filtered to the end of name, then move the picture (TIP: after running the filter script, search the directory filtered for _filtered to see if renaming could be needed) //TODO - allow for changing this
    d. If the Year and Month directories exist and the picture's name is not already in use then move the picture
  3. It will output the move in this format if successful: mv <old_file_name> <year_dir>/<month_dir>/<picture_name>


Usage Example: ruby filter_64.exe -d pictures

**NOTE: Using filter_32.exe on 32-bit operating systems is required**
