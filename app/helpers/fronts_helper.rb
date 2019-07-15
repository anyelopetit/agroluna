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
      case cow.status.status_type
      when 'Service'
        'Lactando con servicio'
      when 'Pregnancy'
        'Lactando preñada'
      when 'Dry'
        'En secado'
      else
        'Lactando sin servicio'
      end
    else
      'Sin lactar'
    end
  end

  def milk_status_date(cow)
    cow.status ? (Date.today - cow.status&.date).to_s.remove('/1') : 'N/A'
  end
end
