require "forwardable"

class LRUCache
  extend Forwardable
  def_delegators :@deque_map, :member?, :delete

  def initialize(max_size)
    @max_size = max_size
    @deque_map = DequeMap.new
  end

  def fetch(key)
    self[key] =
      if member?(key)
        delete(key)
      else
        return unless block_given?
        yield
      end
  end

  private

  def []=(key, val)
    @deque_map.push(key, val).tap do
      next if @deque_map.size <= @max_size
      @deque_map.shift
    end
  end
end

class DequeMap
  extend Forwardable
  def_delegators :@map, :member?, :size, :empty?

  def initialize
    @map = {}
  end

  def push(key, val)
    node = Node.new(key, val)
    @map[key] = node

    node.stitch_in(@head) if @head
    @tail ||= node
    @head = node

    node.val
  end

  def shift
    return if empty?
    delete(@tail.key)
  end

  def delete(key)
    node = @map.delete(key)
    return unless node

    @head = node.succ if node == @head
    @tail = node.pred if node == @tail
    node.stitch_out

    node.val
  end

  class Node
    attr_accessor :pred, :succ
    attr_reader :key, :val

    def initialize(key, val)
      @key = key
      @val = val
    end

    def stitch_in(other)
      stitch_out

      self.succ = other
      self.pred = other.pred

      pred.succ = self if pred
      other.pred = self
    end

    def stitch_out
      pred.succ = succ if pred
      succ.pred = pred if succ

      self.succ = nil
      self.pred = nil
    end
  end
end
