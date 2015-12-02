# ruby_creations
Tasks written in ruby

This 'filter' script is intended to move media (only pictures for now) into the file structure that I use for my media. This saves time when copying from a storage device, and allows for consistent media storage.

File Structure Example:

    Pictures Library > 2015 > 01 January

How it works:

This script will look through the specified directory for any file types that match the photo defaults: .jpg, .png, and .gif (this will be eventually available for modification)

Any that are of those types then have their Modified Date checked, and
  > Output the directory that will be filtered and ask the user for confirmation (aborts if n/no)
  > Check that the Year directory (i.e. 2015) exists

  >If the year directory doesn't exist, create the Year directory. To add all month directories with this creation use --fulldir, then moves the picture

  > If the Year directory exists, and the Month directory (i.e. 06 June) doesn't, it will be created, then moves the picture

  > If the Year directory exists, and the Month directory exists, and the picture name is already used, append _filtered to the end of name, then moves the picture (TIP: after running the filter script, search the directory filtered for _filtered to see if renaming could be needed)

  > If the Year and Month directories exist and the picture's name is not already in use then moves the picture

  > It will output the move in this format if successful: mv [file_name] [year_dir]/[month_dir]/[file_name]

  >Writes to filter_log. Use this to check for any renames or failed copies.


**Usage Example:** ruby filter_64.exe -d pictures -f -a _duplicate

**Options:**

  >-d, --dir [directory] Full path of where to filter. Can use Pictures, Documents, and Desktop for local Library locations. (Defaults to the C:\Users\<CurrentUser>\Pictures)

  > -f, --fulldir When creating a year directory because it didn't exist, add in all the months, not just those that will be necessary.

  > -a, --append [text] When moving over files if a duplicate is found, append this text (Defaults to _filtered)

**NOTE: Using filter_32.exe on 32-bit operating systems is required**
