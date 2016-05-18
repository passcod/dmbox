class Checks
  def initialize
    @good_ips = read_patterns 'ip.whitelist'
    @bad_ips = read_patterns 'ip.blacklist'
  end

  def read_patterns(file)
    File.read(file)
      .split(/\n+/)
      .reject { |pat| pat.start_with? '#' }
  end

  def bad?(key, val)
    if self.respond_to? key.to_sym
      send key.to_sym, val
    else
      false
    end
  end

  def xhr(v)
    return !!v
  end

  def secure(v)
    return !v
  end

  def ip(v)
    @good_ips.each do |pat|
      return false if File.fnmatch? pat, v
    end

    @bad_ips.each do |pat|
      return true if File.fnmatch? pat, v
    end

    false
  end
end
