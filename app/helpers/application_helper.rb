module ApplicationHelper

  def is_admin?
    current_user.try(:is_admin?)
  end

  def admin_zone?
    @top_menu == :admin
  end

  def has_referrer?
    request.referer.present?
  end

  def back_btn(url = nil, caption = nil)
    url ||= request.referrer
    link_to caption || "Back", url, :class => 'btn-back' unless url.blank?
  end

  def variable_pricing_box(entity, field, value, required = false)
    render :partial => 'shared/variable_pricing_box', :locals => { :name => "#{entity}[#{field}]", :value => value, :required => required }
  end

  def wrap_select(html, options = nil)
    options ||= {}
    if options.is_a?(Hash)
      options = options
    elsif options.is_a?(Numeric)
      options = { :style => "width: #{options}px" }
    else
      options = {}
    end
    options[:class] = 'select-wrapper ' + (options[:class] || '')
    "<div #{options.map {|k, v| "#{k}='#{v}'" }.join(' ')}>#{html}</div>".html_safe
  end

  def wrap_date_field(html, options = nil)
    options ||= {}
    if options.is_a?(Hash)
      options = options
    elsif options.is_a?(Numeric)
      options = { :style => "width: #{options}px" }
    else
      options = {}
    end
    options[:class] = 'date-field-wrapper ' + (options[:class] || '')
    "<div #{options.map {|k, v| "#{k}='#{v}'" }.join(' ')}>#{html}</div>".html_safe
  end

  def wrap_switch(builder, property, options = nil)
    options ||= {}
    options = {} unless options.is_a?(Hash)
    options[:class] = 'checkbox-switch-wrapper ' + (options[:class] || '')
    checkbox = builder.check_box(property, :disabled => options[:disabled])
    "<div #{options.map {|k, v| "#{k}='#{v}'" }.join(' ')}><div class='checkbox-switch #{"on" if builder.object[property]} #{"disabled" if options[:disabled]}'><span></span></div>#{checkbox}</div>".html_safe
  end

end
