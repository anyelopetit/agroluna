class TimeService
  def self.months
    %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre]
  end

  def self.months_between_dates(date1, date2)
    minor, major = date1 < date2 ? [date1, date2] : [date2, date1]
    (minor..major).map { |d| I18n.l(d, format: '%B') }.uniq
  end
end
