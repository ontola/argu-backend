# frozen_string_literal: true
module GroupsHelper
  def grant_edge_items(page)
    [[t('grants.all_forums'), page.edge.id]].concat(page.forums.map { |f| [f.display_name, f.edge.id] })
  end
end
