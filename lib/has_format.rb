module HasFormat

  def |(other)
    UnionParser.new(self, other)
  end

  def format(format)
    _set_parser(format, clazz: nil)
  end

  def has_format(format)
    _set_parser(format, clazz: self)
  end

  def parser
    raise ArgumentError, "No format provided" unless @parser
    @parser
  end

  def parse(text)
    parser.parse(text)
  end

  private

  def _set_parser(any, **opts)
    case any
    when UnionParser
      @parser = UnionParser.new(*any.parsers, **opts)
    when HasFormat
      @parser = UnionParser.new(any, **opts)
    when Array
      raise ArgumentError, "Only arrays of size one are currently supported" if any.size != 1
      @parser = ArrayParser.new(any.first, **opts)
    when String, Regexp
      @parser = RegexpParser.new(any, **opts)
    else
      raise ArgumentError, "Unsupported format argument: #{any.inspect}"
    end
  end

  #########################################################################

  class Parser

    attr_reader :regexp

    def initialize(regexp, clazz: nil)
      @regexp = regexp
      @clazz = clazz
    end

    def parse(text)
      if text.chomp =~ /\A#{regexp}\z/
        match = Regexp.last_match
        classify(match) or raise ArgumentError, "Parsed match can not be classified: #{match.inspect}"
      end
    end

  end

  #########################################################################

  class RegexpParser < Parser

    TYPE_REGEXP_MAPPING = {
       i:   /\d+/,
       s:   /\S+/,
       csv: /[0-9, ]+/,
    }

    TYPE_VALUE_MAPPING = {
      i:   ->(v) { v&.to_i },
      s:   ->(v) { v },
      csv: ->(v) { v&.split(/,\s*/)&.map(&:to_i) },
    }

    def initialize(format, clazz: nil)
      @fields = {}
      regexp = format.chomp.gsub(/{{(.+?)}}/) do
        name, type = $1.split(':', 2).reverse.map(&:to_sym)
        type ||= :s
        raise ArgumentError, "#{name} has already been used" if @fields.key?(name)
        @fields[name] = type
        "(?<#{clazz&.name}:#{name}>#{TYPE_REGEXP_MAPPING.fetch(type)})"
      end
      super(Regexp.new(regexp), clazz: clazz)
    end

    def classify(match)
      return nil if match.nil?
      values = @fields.map do |name, type|
        value = match["#{@clazz&.name}:#{name}"]
        TYPE_VALUE_MAPPING.fetch(type).call(value)
      end
      return nil if values.none?

      values = @fields.keys.zip(values).to_h
      if @clazz.nil?
        values
      elsif @clazz < Struct
        @clazz.new(values.values_at(*@clazz.members))
      else
        @clazz.allocate.tap do |obj|
          values.each do |k, v|
            obj.instance_variable_set("@#{k}", v)
          end
          obj.send(:initialize)
        end
      end
    end

  end

  #########################################################################

  class UnionParser < Parser

    def initialize(*classes, **opts)
      raise ArgumentError, "UnionParser classes must all be HasFormat" unless classes.all? { |k| k.is_a?(HasFormat) }

      @classes = classes
      @parsers = @classes.map(&:parser)
      super(Regexp.union(*@parsers.map(&:regexp)), **opts)
    end

    def |(other)
      UnionParser.new(*@classes, other, clazz: @clazz)
    end

    def classify(match)
      @parsers.lazy.filter_map do |parser|
        parser.classify(match)
      end.first
    end

  end

  #########################################################################

  class ArrayParser < Parser

    def initialize(nested, **opts)
      case nested
      when HasFormat
        @nested = nested.parser
      when Parser
        @nested = nested
      else
        raise ArgumentError, "ArrayParser must accept HasFormat or another Parser"
      end
      super(@nested.regexp, **opts)
    end

    def parse(text)
      data = []
      text.chomp.scan(Regexp.union(regexp, /(?<UNEXPECTED>\S.{0,40})/)) do
        match = Regexp.last_match
        raise "Unexpected text encountered: #{match[:UNEXPECTED]}..." if match[:UNEXPECTED]
        parsed = classify(match) or raise "Parsed match can not be classified: #{match.inspect}"
        data << parsed
      end
      @clazz ? @clazz.new(data) : data
    end

    def classify(match)
      @nested.classify(match)
    end

  end

end
