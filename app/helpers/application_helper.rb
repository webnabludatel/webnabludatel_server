# encoding: utf-8

module ApplicationHelper
  def itemize(num, one_item, two_items, five_items)
    "#{num} #{Russian.p(num, one_item, two_items, five_items)}"
  end
end
