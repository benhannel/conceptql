require 'json'
require 'mkmf'
require 'open3'
require 'forwardable'
require_relative 'scope'
require_relative 'nodifier'

module ConceptQL
  class Query
    extend Forwardable
    def_delegators :all, :count, :execute, :order

    attr :statement
    def initialize(db, statement, opts={})
      @db = db
      @statement = extract_statement(statement)
      opts = opts.dup
      opts[:algorithm_fetcher] ||= proc do |alg|
        statement, description = db[:concepts].where(concept_id: alg).get([:statement, :label])
        statement = JSON.parse(statement) if statement.is_a?(String)
        [statement, description]
      end
      @nodifier = opts[:nodifier] || Nodifier.new(opts)
    end

    def query
      nodifier.scope.with_ctes(operator.evaluate(db), db)
    end

    def sql
      sql = query.sql
      if formatter = find_executable('pg_format')
        sql, _ = Open3.capture2(formatter, stdin_data: sql)
      end
    ensure
      return sql
    end

    def annotate
      operator.annotate(db)
    end

    def scope_annotate
      annotate
      nodifier.scope.annotation
    end

    def optimized
      n = dup
      n.instance_variable_set(:@operator, operator.optimized)
      n
    end

    def domains
      operator.domains
    end

    def operator
      @operator ||= if statement.is_a?(Array)
        if statement.first.is_a?(Array)
          Operators::Invalid.new(nodifier, "invalid", errors: [["incomplete statement"]])
        else
          nodifier.create(*statement)
        end
      else
        Operators::Invalid.new(nodifier, "invalid", errors: [["invalid root operator"]])
      end
    end

    private
    attr :db, :nodifier


    def extract_statement(stmt)
      if stmt.is_a?(Array) && stmt.length == 1 && stmt.first.is_a?(Array)
        stmt.first
      else
        stmt
      end
    end
  end
end
