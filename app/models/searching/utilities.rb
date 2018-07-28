module Searching
  module Utilities
    def range_if_present(field, min, max)
      range = {}
      range[:gte] = min if min
      range[:lte] = max if max
      range.present? ? { range: { field => range } } : nil
    end

    # Given a date string, return a date within the acceptable range
    def processed_date(date_string)
      date_string.present? && bounded_date(date_string.to_date)
    rescue ArgumentError
    end

    # By default, ES6 expects yyyy-MM-dd and can't parse years with 4+ digits.
    def bounded_date(date)
      return date.change(year: 0) if date.year.negative?
      return date.change(year: 9999) if date.year > 9999
      date
    end

    def bool_value(str)
      %w(true 1 T).include?(str.to_s)
    end
    alias_method :b, :bool_value

    # Only escape if it isn't already escaped
    def escape_slashes(word)
      word.gsub(/([^\\])\//) { |s| $1 + '\\/' }
    end

    def escape_reserved_characters(word)
      word = escape_slashes(word)
      word.gsub!('!', '\\!')
      word.gsub!('+', '\\\\+')
      word.gsub!('-', '\\-')
      word.gsub!('?', '\\?')
      word.gsub!("~", '\\~')
      word.gsub!("(", '\\(')
      word.gsub!(")", '\\)')
      word.gsub!("[", '\\[')
      word.gsub!("]", '\\]')
      word.gsub!(':', '\\:')
      word
    end

    def split_query_text_phrases(fieldname, text)
      str = ""
      return str if text.blank?
      text.split(",").map(&:squish).each do |phrase|
        str << " #{fieldname}:\"#{phrase}\""
      end
      str
    end

    def split_query_text_words(fieldname, text)
      str = ""
      return str if text.blank?
      text.split(" ").each do |word|
        if word[0] == "-"
          str << " NOT"
          word.slice!(0)
        end
        word = escape_reserved_characters(word)
        str << " #{fieldname}:#{word}"
      end
      str
    end

    def make_bool(query)
      query.reject! { |_, value| value.blank? }
      query[:minimum_should_match] = 1 if query[:should].present?

      if query.values.flatten.size == 1 && (query[:must] || query[:should])
        # There's only one clause in our boolean, so we might as well skip the
        # bool and just require it.
        query.values.flatten.first
      else
        { bool: query }
      end
    end
  end
end