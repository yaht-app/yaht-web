class AddStudyAgreementToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :study_agreement, :boolean
  end
end
