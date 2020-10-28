require 'rails_helper'

RSpec.describe Task, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  describe 'validation' do
    it 'taskが有効であること' do
      task = build(:task)
      expect(task).to be_valid
      expect(task.errors).to be_empty
    end

    it 'titleが入力されていること'do
      task_without_title = build(:task, title: nil)
      expect(task_without_title).to be_invalid
      expect(task_without_title.errors[:title]).to include("can't be blank")
  end

    it 'statusが選択されていること' do
      task_without_status = build(:task, status: nil)
      expect(task_without_status).to be_invalid
      expect(task_without_status.errors[:status]).to include("can't be blank")
    end

    it 'titleが重複していないこと' do
      task = create(:task)
      task_with_duplicated_title = build(:task, title: task.title)
      expect(task_with_duplicated_title).to be_invalid
      expect(task_with_duplicated_title.errors[:title]).to include("has already been taken")
    end

    it '別のタイトルであれば有効になること' do
      task = create(:task)
      task_with_another_title = build(:task, title: "another_title")
      expect(task_with_another_title).to be_valid
      expect(task_with_another_title.errors).to be_empty
    end
  end
end
