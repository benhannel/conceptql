require 'spec_helper'
require 'conceptql'

describe ConceptQL::Query do
  describe '#query' do
    it 'passes request on to tree' do
      yaml = Psych.dump({ icd9: '799.22' })
      mock_tree = Minitest::Mock.new
      mock_node = Minitest::Mock.new
      mock_query = Minitest::Mock.new

      query = ConceptQL::Query.new(Sequel.mock, yaml, mock_tree)
      mock_tree.expect :root, mock_node, [query]
      mock_node.expect :map, [mock_query]
      query.query

      mock_node.verify
      mock_tree.verify
    end
  end
end
