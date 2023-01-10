class PriorityQueue
  def initialize(max_size = Float::INFINITY, &metric)
    @heap = Heap.new(&metric)
    @max_size = max_size
  end

  def enqueue(item)
    if full?
      if belongs?(item)
        @heap.replace(item)
      end
    else
      @heap.insert(item)
    end
  end

  def peek_all
    @heap.peek_all
  end

  private

  def full?
    @heap.size == @max_size
  end

  def belongs?(item)
    @heap > item
  end
end

class Heap
  def initialize(&metric)
    @metric = metric
    @ary = []
  end

  def insert(item)
    @ary << item
    @sift_up ||= Sift::Up.new(self)
    @sift_up.perform
  end

  def replace(item)
    @ary[0] = item
    @sift_down ||= Sift::Down.new(self)
    @sift_down.perform
  end

  def size
    @ary.size
  end

  def >(item)
    @metric.(peek) > @metric.(item)
  end

  def peek_all
    @ary
  end

  private

  def peek
    peek_all[head_i]
  end

  def head_i
    0
  end

  def tail_i
    size - 1
  end

  class Sift
    class << self
      def delegate(*exprs)
        exprs.each do |expr|
          raise "invalid method name" if /[$"A-Z]/ =~ expr
          meth = /^@?(.*)$/.match(expr).captures.first
          define_method(meth) { @heap.instance_eval(expr.to_s) }
        end
      end
    end

    delegate :@ary, :@metric, :head_i, :tail_i

    def initialize(heap)
      @heap = heap
    end

    def perform
      current_i = start_i

      loop do
        next_i = get_next_i(current_i)
        break if current_i == next_i

        swap(current_i, next_i)
        current_i = next_i
      end
    end

    private

    def swap(i, j)
      ary[i], ary[j] = ary[j], ary[i]
    end

    def get_next_i(current_i)
      next_is = get_next_is(current_i)
      next_is << current_i

      next_is.max_by do |i|
        if in_bounds?(i)
          self.class::SIGN * metric.(ary[i])
        else
          -Float::INFINITY
        end
      end
    end

    def in_bounds?(i)
      head_i <= i && i <= tail_i
    end

    class Up < self
      SIGN = -1

      def get_next_is(i)
        [(i - 1) / 2]
      end

      def start_i
        tail_i
      end
    end

    class Down < self
      SIGN = 1

      def get_next_is(i)
        [2 * i + 1, 2 * i + 2]
      end

      def start_i
        head_i
      end
    end
  end
end
