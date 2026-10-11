class BackfillEmptyPage < ActiveRecord::Migration[8.1]
  def up
    Website.where("cardinality(pages) = 0").find_each do |website|
      website.update(pages: [{slug: ""}])
    end
  end

  def down
    # no-op
  end
end
