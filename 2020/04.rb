require_relative '../solve'

EXAMPLE = <<-END
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm

hcl:#cfa07d eyr:2025 pid:166559648
iyr:2011 ecl:brn hgt:59in
END

EXAMPLE2 = <<-END
eyr:1972 cid:100
hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926

iyr:2019
hcl:#602927 eyr:1967 hgt:170cm
ecl:grn pid:012533040 byr:1946

hcl:dab227 iyr:2012
ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277

hgt:59cm ecl:zzz
eyr:2038 hcl:74454a iyr:2023
pid:3556412378 byr:2007

pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980
hcl:#623a2f

eyr:2029 ecl:blu cid:129 byr:1989
iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm

hcl:#888785
hgt:164cm byr:2001 iyr:2015 cid:88
pid:545766238 ecl:hzl
eyr:2022

iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719
END

class PassportBatch

  attr_reader :passports

  def initialize(text)
    @passports = text.split(/\n\n+/).map do |chunk|
      Passport.new(chunk)
    end
  end

end

class Passport

  REQUIRED_FIELDS = {
    'byr' => ->(v) { v =~ /^(\d{4})$/ && (1920..2002).include?($1.to_i) },
    'iyr' => ->(v) { v =~ /^(\d{4})$/ && (2010..2020).include?($1.to_i) },
    'eyr' => ->(v) { v =~ /^(\d{4})$/ && (2020..2030).include?($1.to_i) },
    'hgt' => ->(v) { v =~ /^(\d+)(cm|in)$/ && ($2 == 'cm' ? (150..193) : (59..76)).include?($1.to_i) },
    'hcl' => ->(v) { v =~ /^#[0-9a-f]{6}$/ },
    'ecl' => ->(v) { v =~ /^(amb|blu|brn|gry|grn|hzl|oth)$/ },
    'pid' => ->(v) { v =~ /^\d{9}$/ },
  }

  def initialize(chunk)
    @fields = chunk.split(/\s+/).map do |f|
      f.split(':', 2)
    end.to_h 
  end

  def required_fields_exists?
    (REQUIRED_FIELDS.keys - @fields.keys).empty?
  end

  def valid?
    required_fields_exists? && \
    REQUIRED_FIELDS.all? do |field, validation|
      validation.call(@fields.fetch(field))
    end
  end

end

solve_with(PassportBatch, :text, EXAMPLE => 2) do |batch|
  batch.passports.count(&:required_fields_exists?)
end

solve_with(PassportBatch, :text, EXAMPLE2 => 4) do |batch|
  batch.passports.count(&:valid?)
end
