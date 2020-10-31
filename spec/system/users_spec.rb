require 'rails_helper'

RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }
  # before do
  #   driven_by(:rack_test)
  # end

  # pending "add some scenarios (or delete) #{__FILE__}"
  describe 'ログイン前' do
    context 'フォームの入力値が正常' do
      it 'ユーザーの新規作成が成功する' do
        visit new_user_path
        fill_in 'Email', with: 'email@example.com'
        fill_in 'Password', with: 'password'
        fill_in 'Password confirmation', with: 'password'
        click_button 'SignUp'
        expect(page).to have_content 'User was successfully created.'
        expect(current_path).to eq login_path
      end
    end

    context 'メールアドレス未入力' do
      it 'ユーザーの新規作成に失敗する' do
        visit new_user_path
        fill_in 'Email', with: ""
        fill_in 'Password', with: 'password'
        fill_in 'Password confirmation', with: 'password'
        click_button 'SignUp'
        expect(current_path).to eq users_path
        expect(page).to have_content "mail can't be blank"
      end
    end

    context '登録済みのメールアドレスを使用' do
      it 'ユーザーの作成に失敗する' do
        visit new_user_path
        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'password'
        fill_in 'Password confirmation', with: 'password'
        click_button 'SignUp'
        expect(current_path).to eq users_path
        expect(page).to have_content "Email has already been taken"
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit user_path(user)
          expect(current_path).to eq login_path
          expect(page).to have_content "Login required"
        end
      end
    end
  end

  describe 'ログイン後' do
    before { login_as(user) }

    describe 'ユーザー編集' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          visit edit_user_path(user)
          fill_in 'Email', with: 'update@example.com'
          fill_in 'Password', with: 'update_password'
          fill_in 'Password confirmation', with: 'update_password'
          click_button 'Update'
          expect(page).to have_content('User was successfully updated.')
          expect(current_path).to eq user_path(user)
        end
      end

      context 'メールアドレスが未入力' do
        it 'ユーザーの編集に失敗する' do
          visit edit_user_path(user)
          fill_in 'Email', with: ""
          fill_in 'Password', with: 'password1'
          fill_in 'Password confirmation', with: 'password1'
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content "Email can't be blank"
          expect(page).to have_content "1 error prohibited this user from being saved"
        end
      end

      context '登録済みのメールアドレスを使用' do
        it 'ユーザーの編集に失敗する' do
          visit edit_user_path(user)
          other_user = create(:user)
          fill_in 'Email', with: other_user.email
          fill_in 'Password', with: 'password1'
          fill_in 'Password confirmation', with: 'password1'
          click_button 'Update'
          expect(current_path).to eq user_path(user)
          expect(page).to have_content "Email has already been taken"
          expect(page).to have_content "1 error prohibited this user from being saved"
        end
      end

      context '他ユーザーの編集ページにアクセス' do
        it '編集ページへのアクセスに失敗する' do
          other_user = create(:user)
          visit edit_user_path(other_user)
          expect(current_path).to eq user_path(user)
          expect(page).to have_content "Forbidden access."
        end
      end
    end

    describe 'マイページ' do
      context 'タスクを作成' do
        it '新規作成したタスクが表示される' do
          create(:task, title: 'test_title', status: :todo, user: user)
          visit user_path(user)
          expect(page).to have_content "You have 1 task."
          expect(page).to have_content "test_title"
          expect(page).to have_content "todo"
          expect(page).to have_link "Show"
          expect(page).to have_link "Edit"
          expect(page).to have_link "Destroy"
        end
      end
    end
  end
end
