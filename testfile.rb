  def makeDateTime(dateString)
    split = dateString.split(',')
    monthString = ""
    monthNum = 0
    if split[1].include? "Jan"
      monthString = "Jan"
      monthNum = 1
    elsif split[1].include? "Feb"
      monthString = "Feb"
      monthNum = 2
    elsif split[1].include? "Mar"
      monthString = "Mar"
      monthNum = 3
    elsif split[1].include? "Apr"
      monthString = "Apr"
      monthNum = 4
    elsif split[1].include? "May"
      monthString = "May"
      monthNum = 5
    elsif split[1].include? "Jun"
      monthString = "Jun"
      monthNum = 6
    elsif split[1].include? "Jul"
      monthString = "Jul"
      monthNum = 7
    elsif split[1].include? "Aug"
      monthString = "Aug"
      monthNum = 8
    elsif split[1].include? "Sep"
      monthString = "Sep"
      monthNum = 9
    elsif split[1].include? "Oct"
      monthString = "Oct"
      monthNum = 10
    elsif split[1].include? "Nov"
      monthString = "Nov"
      monthNum = 11
    elsif split[1].include? "Dec"
      monthString = "Dec"
       monthNum = 12
    end
    dayOfMonth = (split[1].gsub! monthString, '').to_i
    splitTime = split[2].split(':')
    hour = splitTime[0].to_i
    ampm = "PM"
    ampm = "AM" unless splitTime[1].include?"PM"
    hour += 12 if ampm == "PM"
    minutes = (splitTime[1].gsub! ampm, '').to_i
    year = Date.today.year
    year += 1 if Date.today.month > monthNum
    DateTime.new(year, monthNum, dayOfMonth, hour, minutes)
  end
