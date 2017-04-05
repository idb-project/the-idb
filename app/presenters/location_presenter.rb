class LocationPresenter < Keynote::Presenter
  presents :location

  delegate :id, :name, :location_id, :description, :self_and_ancestors, :location_name, :children,
           to: :location

  def location_link
    return "" unless location
    names = Array.new()
    location.self_and_ancestors.to_a.reverse.each do |item|
      names.push(link_to(item.name, item))
    end
    names.join(" → ").html_safe
  end

  def location_tree(onclick=nil,level=0)
    inner = build_html do
      li do
        input type: "checkbox", id: "node-#{self.id}", class: "tree-checkbox"
        label for: "node-#{self.id}", class: "tree-checkbox-label" do
          if not self.children.empty?
            i class: "fa fa-plus-square tree-expand"
            i class: "fa fa-minus-square tree-collapse"
          else
            i class: "fa fa-square"
          end
        end
        if onclick
          span class: "tree-name-label", onclick: "#{onclick}(#{self.id})" do
            text self.name
          end
        else
          span class: "tree-name-label" do
            text self.name
          end
        end
        if not self.children.empty?
          ul do
            children = self.children.sort_by { |child| child.name}
            children.each do |child|
              text k(child).location_tree(onclick,level+1)
            end
          end
        end
      end
    end
    if level == 0
      out = build_html do
        ul class: "tree" do
          text inner
        end
      end
      return out
    end
    return inner
  end
end
