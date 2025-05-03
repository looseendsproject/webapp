# frozen_string_literal: true

# Time format helpers

# time = Time.now                     # => Thu Jan 18 06:10:17 CST 2007

# time.to_formatted_s(:time)          # => "06:10"
# time.to_s(:time)                    # => "06:10"


# Built-in

# time.to_formatted_s(:db)            # => "2007-01-18 06:10:17"
# time.to_formatted_s(:number)        # => "20070118061017"
# time.to_formatted_s(:short)         # => "18 Jan 06:10"
# time.to_formatted_s(:long)          # => "January 18, 2007 06:10"
# time.to_formatted_s(:long_ordinal)  # => "January 18th, 2007 06:10"
# time.to_formatted_s(:rfc822)        # => "Thu, 18 Jan 2007 06:10:17 -0600"

# %a - The abbreviated weekday name (``Sun'')
# %A - The  full  weekday  name (``Sunday'')
# %b - The abbreviated month name (``Jan'')
# %B - The  full  month  name (``January'')
# %c - The preferred local date and time representation
# %d - Day of the month (01..31)
# %e - Day of the month without leading 0 (1..31)
# %g - Year in YY (00-99)
# %H - Hour of the day, 24-hour clock (00..23)
# %I - Hour of the day, 12-hour clock (01..12)
# %j - Day of the year (001..366)
# %m - Month of the year (01..12)
# %M - Minute of the hour (00..59)
# %p - Meridian indicator (``AM''  or  ``PM'')
# %S - Second of the minute (00..60)
# %U - Week  number  of the current year,
#         starting with the first Sunday as the first
#         day of the first week (00..53)
# %W - Week  number  of the current year,
#         starting with the first Monday as the first
#         day of the first week (00..53)
# %w - Day of the week (Sunday is 0, 0..6)
# %x - Preferred representation for the date alone, no time
# %X - Preferred representation for the time alone, no date
# %y - Year without a century (00..99)
# %Y - Year with century
# %Z - Time zone name
# %% - Literal ``%'' character

#  t = Time.now
#  t.strftime("Printed on %m/%d/%Y")   #=> "Printed on 04/09/2003"
#  t.strftime("at %I:%M%p")            #=> "at 08:56AM"

# Custom

Time::DATE_FORMATS[:month_and_year] = "%B %Y" # January 2025
Time::DATE_FORMATS[:human] = "%a %b %d, %Y %I:%M%p %Z" # Thu Apr 03, 2025 02:08AM UTC
Time::DATE_FORMATS[:compact] = "%m/%d/%y %I:%M%p %Z" # 04/6/25 08:53AM -5:00
