require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create(:user) }
  let(:task) { create(:task) }
  # before do
  #   driven_by(:rack_test)
  # end

  # pending "add some scenarios (or delete) #{__FILE__}"
  describe 'ログイン前' do
    context 'ページ遷移確認' do
      context 'タスクの新規登録ページにアクセス' do
        it '新規登録ページへのアクセスが失敗する' do
          visit new_task_path
          expect(current_path).to eq login_path
          expect(page).to have_content "Login required"
        end
      end

      context 'タスクの編集ページにアクセス' do
        it '編集ページへのアクセスに失敗する' do
          visit edit_task_path(task)
          expect(current_path).to eq login_path
          expect(page).to have_content "Login required"
        end
      end

      context 'タスクの詳細ページにアクセス' do
        it 'タスクの詳細ページが表示される' do
          visit task_path(task)
          expect(current_path).to eq task_path(task)
          expect(page).to have_content task.title
        end
      end

      context 'タスクの一覧ページにアクセス' do
        it '全てのユーザーのタスク情報が表示される' do
          tasks = create_list(:task, 3)
          visit tasks_path
          expect(current_path).to eq tasks_path
          expect(page).to have_content tasks[0].title
          expect(page).to have_content tasks[1].title
          expect(page).to have_content tasks[2].title
        end
      end
    end
  end

  describe 'ログイン後' do
    before { login_as(user) }

    describe 'タスク新規登録' do
      context 'フォームの入力値が正常' do
        it 'タスクの新規作成が成功する' do
          visit new_task_path
          fill_in "Title", with: "a"
          fill_in "Content", with: "i"
          select "doing", from: "Status"
          fill_in "Deadline", with: DateTime.new(1991, 9, 17, 12, 12)
          click_button "Create Task"
          expect(current_path).to eq '/tasks/1'
          expect(page).to have_content "Title: a"
          expect(page).to have_content "Content: i"
          expect(page).to have_content "Status: doing"
          expect(page).to have_content "Deadline: 1991/9/17 12:12"
        end
      end

      context '登録済みのタイトルを入力' do
        it 'タスクの新規作成に失敗する' do
          visit new_task_path
          fill_in "Title", with: task.title
          fill_in "Content", with: "i"
          select "doing", from: "Status"
          fill_in "Deadline", with: DateTime.new(1991, 9, 17, 12, 12)
          click_button "Create Task"
          expect(current_path).to eq tasks_path
          expect(page).to have_content "1 error prohibited this task from being saved"
          expect(page).to have_content "Title has already been taken"
        end
      end
    end

    describe 'タスク編集' do
      let!(:task) { create(:task, user:user) }
      let(:other_task) { create(:task, user: user) }
      before { visit edit_task_path(task) }

      context 'フォームの入力値が正常' do
        it 'タスクの編集に成功する' do
          fill_in "Title", with: "title"
          select "doing", from: "Status"
          click_button "Update Task"
          expect(current_path).to eq '/tasks/1'
          expect(page).to have_content "Task was successfully updated."
          expect(page).to have_content "Title: title"
          expect(page).to have_content "Status: doing"
        end
      end

      context 'タイトルが未入力' do
        it 'タスクの編集が失敗する' do
          fill_in "Title", with: ""
          select "doing", from: "Status"
          click_button "Update Task"
          expect(current_path).to eq task_path(task)
          expect(page).to have_content "1 error prohibited this task from being saved:"
          expect(page).to have_content "Title can't be blank"
        end
      end

      context '登録済みのタイトルを入力' do
        it 'タスクの編集が失敗する' do
          fill_in "Title", with: other_task.title
          select "doing", from: "Status"
          click_button "Update Task"
          expect(current_path).to eq task_path(task)
          expect(page).to have_content "1 error prohibited this task from being saved:"
          expect(page).to have_content "Title has already been taken"
        end
      end
    end

    describe 'タスク削除' do
      let!(:task) { create(:task, user: user) }

      it 'taskの削除が成功する' do
        visit tasks_path
        click_link "Destroy"
        expect(page.accept_confirm).to eq "Are you sure?"
        expect(current_path).to eq tasks_path
        expect(page).to have_content "Task was successfully destroyed"
        expect(page).to_not have_content task.title
      end
    end
  end
end
