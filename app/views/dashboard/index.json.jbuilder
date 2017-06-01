json.array!(@dashboards) do |dash|
  json.extract! dash, :id, :email, :first_name, :last_name
 
end


