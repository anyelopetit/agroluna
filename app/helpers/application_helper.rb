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
    path_array = request.env['PATH_INFO'].split('/')[1..-2]
    final_array = []
    i = 0
    while i < path_array.size
      if path_array[i + 1].to_i.zero?
        final_array.push(path_array[i].to_sym)
        i += 1
      else
        final_array.push(find_model(path_array, i).find(path_array[i + 1]))
        i += 2
      end
    end
    final_array
  end

  def find_model(path_array, i)
    parent_module = controller.class.parent.to_s.underscore.remove('/admin')
    "#{parent_module}/#{path_array[i]}".classify.constantize
  end

  def object_name(object, attribute_name)
    attribute = attribute_name.split('_id').first.to_sym
    object.try(attribute).name
  end
end


