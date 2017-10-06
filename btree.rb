class BTree
  attr_reader :capacity

  def initialize(values, capacity)
    @capacity = capacity
    @root = Node.new(parent: nil, tree: self, values: values.sort)
  end

  def lookup(value)
    @root.lookup(value)
  end

  def insert(value)
    @root.insert(value)
  end

  def upsert(root)
    @root = Node.new(parent: nil, tree: self, values: [root.middle_value], nodes: root.split)
  end

  class Node
    attr_writer :parent

    def initialize(parent:, tree:, values: [], nodes: [])
      @parent = parent
      @tree = tree
      @values = values
      @nodes = nodes
      @nodes.each { |node| node.parent = self }
    end

    def lookup(value)
      return false if @values.empty?
      index = @values.bsearch_index { |v| v > value}
      return true if @values[(index || 0) - 1] == value
      return false if leaf?

      if index
        @nodes[index].lookup(value)
      else
        @nodes[-1].lookup(value)
      end
    end

    def insert(value)
      if leaf?
        add(value)
        if overfull?
          if root?
            @tree.upsert(self)
          else
            @parent.upsert(self)
          end
        end
      else
        child_node = value_node(value)
        child_node.insert(value)
      end
      value
    end

    def split
      return unless overfull?
      lhs_node = Node.new(parent: @parent, tree: @tree, values: left_values, nodes: left_nodes)
      rhs_node = Node.new(parent: @parent, tree: @tree, values: right_values, nodes: right_nodes)
      [lhs_node, rhs_node]
    end

    def middle_value
      return unless overfull?
      @values[@tree.capacity - 1]
    end

    def inspect
      "#<Node: @values=#{@values}, @nodes=#{@nodes}>"
    end

    protected

    def upsert(child_node)
      index = add(child_node.middle_value)
      nodes = child_node.split
      @nodes.delete_at(index)
      @nodes.insert(index, *nodes)

      if overfull?
        if root?
          @tree.upsert(self)
        else
          @parent.upsert(self)
        end
      end
    end

    private

    def overfull?
      @values.count >= 2 * @tree.capacity - 1
    end

    def root?
      !@parent
    end

    def leaf?
      @nodes.empty?
    end

    def left_values
      return unless overfull?
      @values[0..(@tree.capacity - 2)]
    end

    def right_values
      return unless overfull?
      @values[(@tree.capacity)..-1]
    end

    def left_nodes
      return unless overfull?
      return [] if leaf?
      @nodes[0..(@tree.capacity - 1)]
    end

    def right_nodes
      return unless overfull?
      return [] if leaf?
      @nodes[(@tree.capacity)..-1]
    end

    def add(value)
      index = @values.bsearch_index { |v| v > value }
      if index
        @values.insert(index, value)
        index
      else
        @values.push(value)
        @values.size - 1
      end
    end

    def value_node(value)
      index = @values.bsearch_index { |v| v > value}
      @nodes[index || -1]
    end
  end
end