class KeyGenerator
  def self.generate_from_string(text)
    text.downcase.gsub(/[^a-z -]/, "").tr(" ", "-")
  end
end