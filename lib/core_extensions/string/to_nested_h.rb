module CoreExtensions
  module String
    module ToNestedH
      def to_nested_h(sep: '.')
        self.split(sep).reverse.inject{ |a, n| { n => a } }
      end
    end
  end
end
