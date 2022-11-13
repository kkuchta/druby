require 'method_source'
require 'syntax_tree'

class BlockFinder < SyntaxTree::Visitor
  attr_reader :first_block
  visit_method def visit_do_block(node)
    @first_block ||= node
 end
  visit_method def visit_brace_block(node)
    @first_block ||= node
 end
end

def serialize_block(&block)
  source = block.source
  root = SyntaxTree.parse(source)
  visitor = BlockFinder.new
  visitor.visit(root)
  block_node = visitor.first_block
  formatter = SyntaxTree::Formatter.new(source, [], 80)
  formatter.instance_variable_set(:@stack, [proc {SyntaxTree::Program.new(statements: [], location: nil)}])
  formatter.format(block_node)
  formatter.flush
  formatter.output.join
end

class Proc
  def _dump(depth)
    serialize_block(&self)
  end
  def self._load(a_proc_string)
    eval('proc ' + a_proc_string)
  end
end