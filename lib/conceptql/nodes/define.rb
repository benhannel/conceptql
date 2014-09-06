require_relative 'node'

module ConceptQL
  module Nodes
    # Mimics creating a variable name that stores an itermediate result as
    # part of a larger concept
    #
    # The idea is that a concept might be very complex and it helps to break
    # that complex concept into a set of sub-concepts to better understand it.
    #
    # Also, sometimes a particular piece of a concept is used in many places,
    # so it makes sense to write that piece out once, store it as a "variable"
    # and then insert that variable into the concept as needed.
    # run the query once and subsequent calls
    class Define < Node
      # Create a temporary table and store the stream of  results in that table.
      # This "caches" the results so we only have to execute stream's query
      # once.
      #
      # The logic here is that if something is assigned to a variable, chances
      # are that it will be used more than once, so why run the query more than
      # once?
      #
      # ConceptQL's SQL generator normally translates the entire statement into
      # one, large query that can be executed later.
      #
      # Unfortunately, Sequel's "create_table" function actually executes the
      # 'CREATE TABLE' SQL right away, meaning that the "define" node will
      # execute immediately _during_ the processing of the ConceptQL statement.
      # We'll see what kinds of problems this causes
      #
      # Lastly, this node does NOT pass its results to the next node.  The
      # reason for this exception is to allow us to return the SQL that
      # generates the temp table.  This is done so that the ConceptQL sandbox
      # can return the entire set of SQL statements needed to run a query.
      #
      # Perhaps in the future we can find a way around this.
      #
      # Also, things will blow up if you try to use a variable that hasn't been
      # defined yet.
      def query(db)
        # We'll wrap the creation of the temp table in memoization
        # That way we can call #query multiple times, but only suffer the
        # cost of creating the temp table just once
        @_run ||= begin
          db.create_table!(table_name, temp: true, as: stream.evaluate(db))
          true
        end
        db.from(table_name)
      end

      def types
        stream.types
      end

      def sql(db)
        db[db.send(:create_table_as_sql, table_name, stream.evaluate(db).sql, temp: true)].sql
      end

      def scope=(s)
        if scope
          scope.remove_definition(name)
        end
        super
        scope.add_definition(name, self)
      end

      def table_name
        @table_name ||= namify(name)
      end
      private

      def name
        arguments.first
      end
    end
  end
end

