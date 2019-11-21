# frozen_string_literal: true

# FrontsHelper
module FrontsHelper
  def set_head
    render 'layouts/keppler_frontend/app/layouts/head'
  end

  def keppler_editor
    render 'layouts/keppler_frontend/app/layouts/keppler_editor'
  end

  def basic_info
    Setting.first
  end

  def set_social
    Setting.first.social_account
  end

  def permit_users(roles)
    roles = [] << roles if roles.class.to_s.eql?('String')
    permit = false
    if current_user
      roles.each { |r| permit = true if r.eql?(current_user.rol) }
    end
    permit
  end

  def permit_users_or_redirect_to(roles, path)
    roles = [] << roles if roles.class.to_s.eql?('String')
    permit = false
    if current_user
      roles.each { |r| permit = true if r.eql?(current_user.rol) }
    end
    redirect_to path if permit.eql?(false)
  end

  def milk_status(cow)
    if cow&.milking
      case cow.status&.status_type
      when 'Service'
        'Lac. C/Servicio'
      when 'Pregnancy'
        'Preñada'
      when 'Dry'
        'En Secado'
      else
        'Lac. S/Servicio'
      end
    else
      'Sin lactar'
    end
  end

  def milk_status_days(cow)
    cow.status ? (Date.today - cow.status&.date).to_s.remove('/1').to_i : 'N/A'
  end

  def next_process(cow)
    case cow.status_name
    when 'Nil' || nil
      :days_to_service
    when 'Service'
      :days_to_pregnancy
    when 'Pregnancy'
      :days_to_dry
    when 'Dry'
      :days_to_rest
    else
      ''
    end
  end
end
