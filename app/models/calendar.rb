class Calendar < ApplicationRecord
  self.table_name = "calendar"
  self.primary_key = :service_id
end
