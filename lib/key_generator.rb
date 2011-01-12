require 'unidecode'

class KeyGenerator
  def self.generate_from_string(text)
    text.gsub(/[-‐‒–—―⁃−­]/, '-').to_ascii.downcase.gsub(/[^a-z0-9 ]/, ' ').strip.gsub(/[ ]+/, '-')
  end
end