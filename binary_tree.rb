class BinaryTree
  def initialize(values)
    values = [values] unless values.is_a?(Array)
    @root = Node.new(values.shift)
    values.each { |value| insert(value) }
  end

  def insert(value)
    @root.insert(value)
  end

  def include?(value)
    @root.include?(value)
  end

  def to_a
    @root.to_a
  end

  class EmptyNode
    def insert(*)
      false
    end

    def include?(*)
      false
    end

    def to_a
      []
    end
  end

  class Node
    def initialize(value)
      @value = value
      @left_node = EmptyNode.new
      @right_node = EmptyNode.new
    end

    def insert(value)
      case @value <=> value
        when 1 then insert_left(value)
        when -1, 0 then insert_right(value)
      end
    end

    def include?(value)
      case @value <=> value
        when 1 then @left_node.include?(value)
        when -1 then @right_node.include?(value)
        else true
      end
    end

    def to_a
      @left_node.to_a + [@value] + @right_node.to_a
    end

    private

    def insert_left(value)
      if @left_node.is_a?(EmptyNode)
        @left_node = Node.new(value)
      else
        @left_node.insert(value)
      end
    end

    def insert_right(value)
      if @right_node.is_a?(EmptyNode)
        @right_node = Node.new(value)
      else
        @right_node.insert(value)
      end
    end
  end
end