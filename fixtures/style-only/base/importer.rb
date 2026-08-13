class Importer
  def initialize(rows)
    @rows = rows
  end

  def run
    @rows.map { |row| normalise(row) }
  end

  private

  def normalise(row)
    { name: row[:name].to_s.strip, age: row[:age].to_i }
  end
end
