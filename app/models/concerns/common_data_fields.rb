module CommonDataFields
  def title
    data_fields.find { |data_field| data_field.custom_field.title_field? }.try(:value)
  end

  def description
    data_fields.find { |data_field| data_field.custom_field.description_field? }.try(:value)
  end

  def make
    data_fields.find { |data_field| data_field.custom_field.make_field? }.try(:value)
  end

  def model
    data_fields.find { |data_field| data_field.custom_field.model_field? }.try(:value)
  end
end