module HomeHelper
  def post_count(tag_name, type)
    Tag.tagged_node_count(tag_name, type)
  end
end
