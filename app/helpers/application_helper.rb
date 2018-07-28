module ApplicationHelper
  # Given an array of hashes, each of which has a name and url
  # Return a list of links as a delimited string
  def link_list_joiner(group, opt={})
    links = group.map{ |item| link_to item[:name], item[:url] }
    if opt[:sentence]
      links.to_sentence.html_safe
    else
      links.join(', ').html_safe
    end
  end
end
