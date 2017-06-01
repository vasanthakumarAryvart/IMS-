module ListingHelper

  def categories_options_for_select(categories_list = ItemCategory.top_level_categories, selected_category_id = nil)
    options_for_select(recursive_sorted_categories_list(categories_list).map { |c| [("&nbsp;" * c[:indent] * 4).html_safe + c[:title], c[:id]] }, selected_category_id)
  end

  def recursive_sorted_categories_list(categories_list = ItemCategory.top_level_categories)
    recursive_categories = Proc.new { |categories, indent|
      categories.map { |category|
        [{ :title => category.title, :indent => indent, :id => category.id }] + recursive_categories.call(category.child_categories, indent + 1)
      }
    }
    recursive_categories.call(categories_list.sort_by(&:title), 0).flatten
  end
end
