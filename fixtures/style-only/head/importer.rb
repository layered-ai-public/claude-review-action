class Importer
  def initialize(rows)
    @rows = rows
  end

  def run
    r = []
    @rows.each do |x|
      if x[:age].to_i >= 18
        if x[:name].to_s.strip != ''
          r << normalise(x)
        end
      end
    end
    r
  end

  private

  def normalise(x)
    { name: x[:name].to_s.strip, age: x[:age].to_i, adult: true }
  end
end
