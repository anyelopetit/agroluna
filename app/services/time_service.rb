class TimeService
  def self.months
    %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octumbre Noviembre Diciembre]
  end

  def self.months_between_dates(d1, d2)
    minor, major = d1 < d2 ? [d1, d2] : [d2, d1]
    (minor..major).map { |d| I18n.l(d, format: "%B") }.uniq
  end
end