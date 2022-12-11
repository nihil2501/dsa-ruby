module Memoize
  module ClassMethods
    def memoize(meth)
      unless defined?(@memoize_module)
        @memoize_module = Module.new
        prepend @memoize_module
      end

      @memoize_module.define_method(meth) do |*args|
        @memoize_cache ||= {}
        cache = (@memoize_cache[meth] ||= {})
        cache.fetch(args) { cache[args] = super(*args) }
      end
    end
  end

  class << self
    def included(receiver)
      receiver.extend ClassMethods
    end
  end
end
