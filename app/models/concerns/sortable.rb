module Sortable
  # Returns a lower case, non-article-beginning string
  # suitable for sorting on
  def make_sortable(str)
    str.strip.downcase.delete(article_removing_regex)
  end

  private

  def article_removing_regex
    Regexp.new(/^(a|an|the|la|le|les|l'|un|une|des|die|das|il|el|las|los|der|den)\s/i)
  end
end
