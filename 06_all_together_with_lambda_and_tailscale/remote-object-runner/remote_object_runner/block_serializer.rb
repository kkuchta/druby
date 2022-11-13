require 'method_source'
require 'syntax_tree'

# Create a node visitor that walks the syntax tree looking for blocks.
class BlockFinder < SyntaxTree::Visitor
  attr_reader :first_block
  visit_method def visit_do_block(node)
    @first_block ||= node
    # Don't traverse further
  end
  visit_method def visit_brace_block(node)
    @first_block ||= node
    # Don't traverse further
  end
end

def serialize_block(&block)
  # Get the un-trimmed source lines containing this block including some cruft
  # outside the block (including method invocation, assignment, that sort of
  # thing).  This is from method_source, but it's just using `.source_location`
  # under the hood to get a filename + line number.
  source = block.source
  # binding.pry

  # We need to turn `foo = bar({|x| x + 1})` into just `{|x| x + 1}`, so parse
  # it into a syntax tree.
  root = SyntaxTree.parse(source)

  # Now lets find the first, highest-level block in that syntax tree
  visitor = BlockFinder.new
  visitor.visit(root)
  block_node = visitor.first_block

  # Turn the syntax tree back into a ruby string using SyntaxTree's formatter
  formatter = SyntaxTree::Formatter.new(source, [], 80)

  # `{|x| x + 1}1 is not valid ruby, so trick the formatter into thinking it's
  # part of an overall program node
  formatter.instance_variable_set(:@stack, [proc {SyntaxTree::Program.new(statements: [], location: nil)}])

  # Return the formatter output
  formatter.format(block_node)
  formatter.flush
  formatter.output.join
end

class Proc
  def _dump(depth)
    dump_output = serialize_block(&self)
    dump_output
  end
  def self._load(a_proc_string)
    eval('proc ' + a_proc_string)
  end
end