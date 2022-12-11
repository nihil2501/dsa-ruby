class Trie
  SENTINEL = Object.new

  def initialize
    @tries = {}
  end

  def insert(word)
    each = word.each_char
    each = each.chain([SENTINEL])
    each.reduce(self) do |trie, char|
      trie.set(char)
    end

    self
  end

  def fetch(word)
    each = word.each_char
    each.reduce(self) do |trie, char|
      trie.get(char) or return
    end
  end

  def sentinel?
    @tries.member?(SENTINEL)
  end

  protected

  def set(char)
    @tries[char] ||= Trie.new
  end

  def get(char)
    @tries[char]
  end
end
