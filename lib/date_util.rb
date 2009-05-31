module DateUtil
  
  def self.hour(time)
    return time.strftime("%H")
  end
  
  def self.weekday_name(time)
    return time.strftime("%a")
  end
  
  def self.f_date(date)
    date.strftime("%d.%m.%y") if date
  end
  
  def self.f_date_time(date)
    date.strftime("%d.%m.%y %H:%M") if date
  end
  
  def self.str_sql_date_time(datetime)
    datetime.strftime("%Y-%m-%d %H:%M:%S.0") if datetime
  end
end