class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.sync_csv(content)
    primary_key_str = primary_key.to_s
    # count = 0
    parsed = CSV.parse(content, headers: true, encoding: "UTF-8")
    puts "Syncing #{table_name}, #{parsed.length} lines"
    parsed.each do |col|
      # puts "Processing line #{count}/#{parsed.length}"
      # count += 1

      key = if primary_key.is_a?(Array)
              primary_key.map { |key_name| col[key_name] }
            else
              col[primary_key_str]
            end

      old_record = find(key)

      yield(col) if block_given?

      hash_col = col.to_h
      unless old_record
        new_record = create(hash_col)
        puts "Created record #{new_record[primary_key_str]}"
        next
      end
      next if old_record.attributes == hash_col

      diff = Hashdiff.diff(hash_col, old_record.attributes)
      puts "Updating #{old_record[primary_key_str]} (change, field, new, old): #{diff}"

      old_record.attributes = hash_col
      old_record.save
    end
  end
end
