# frozen_string_literal: true

# ObjectQuery
module ObjectQuery
  extend ActiveSupport::Concern

  ### Traidos de Admin

  # Get submit key to redirect, only [:create, :update]
  def redirect(object, commit)
    redirect_to(
      {
        action: (commit.key?('_save') ? :show : :new),
        id: (object.id if commit.key?('_save'))
      },
      notice: actions_messages(object)
    )
  end

  def redefine_ids(rocket, ids)
    ids.delete('[]').split(',').select do |id|
      id if frontend_model(rocket).exists? id
    end
  end

  # Check whether the user has permission to delete
  # each of the selected objects
  def can_multiple_destroy
    redefine_ids(params[:multiple_ids]).each do |id|
      authorize model.find_by(id: id)
    end
  end

  private

  def redirect_to_index(objects)
    return if listing? && (objects.first_page? || !objects.size.zero?)
    redirect_to(
      {
        action: :index,
        page: (@current_page.to_i if params[:page]),
        search: @query
      },
      notice: actions_messages(model.new)
    )
  end

  def send_format_data(objects, extension)
    models = objects.model.to_s.downcase.pluralize
    t_models = t("keppler.models.pluralize.#{models}").humanize
    filename = "#{t_models} - #{I18n.l(Time.now, format: :short)}"
    objects_array = objects.order(:created_at)
    case extension
    when 'csv'
      send_data objects_array.to_csv, filename: "#{filename}.csv"
    when 'xls'
      send_data objects_array.to_a.to_xls, filename: "#{filename}.xls"
    end
  end

  def respond_to_formats(objects)
    respond_to do |format|
      format.html
      format.csv { send_format_data(objects.model.all, 'csv') }
      format.xls { send_format_data(objects.model.all, 'xls') }
      format.json { render json: json_objects(objects) }
    end
  end

  protected

  def json_objects(objects)
    # if request.url.include?('page')
    objects.page(@current_page).order(position: :desc)
    # else
    #   objects.model.all
    # end
  end
end
