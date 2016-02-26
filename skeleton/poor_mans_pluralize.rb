#String Conversion


def poor_mans_pluralize(klass)
  word = klass.to_s.scan(/[A-Z][a-z]+/).join('_').downcase
  word[-1].match(/[sxzh]/) ? word << "es" : word << "s"
  word
end
