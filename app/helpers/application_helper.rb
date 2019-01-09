# frozen_string_literal: true

# ApplicationHelper -> Helpers base
module ApplicationHelper
  # Title dinamic in all keppler
  def title(page_title)
    content_for(:title) { page_title }
  end

  # Meta Descriotion dinamic in all keppler
  def meta_description(page_description)
    content_for(:description) { page_description }
  end

  # True if a user is logged
  def loggedin?
    current_user
  end

  def can?(model)
    Pundit.policy(current_user, model)
  end

  def landing?
    controller_name.eql?('front') && action_name.eql?('index')
  end

  def model_object
    parent = controller.class.parent.to_s.underscore
    return [:admin] if parent.eql?('admin')
    parent_sym = parent.remove('keppler_').split('/').first.to_sym
    nested_rocket unless model.reflect_on_all_associations(:belongs_to).count.zero?
    [:admin, parent_sym]
  end
end

def nested_rocket
  # model.reflect_on_all_associations(:belongs_to).each do |assoc|
  #   father = assoc.active_record.name.constantize
  #   father_sym = "#{father}_id".underscore.to_sym
  #   return [:admin, parent_sym, father.try(father_sym)]
  # end
  controller_path.remove('admin/')
end
