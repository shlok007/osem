require 'spec_helper'

describe Admin::UsersController do
  let(:organization) { create(:organization) }
  let(:conference) { create(:conference) }
  let(:role_organization_admin) { Role.find_by(name: 'organization_admin', resource: organization) }
  let(:user_organization_admin) { create(:user, role_ids: [role_organization_admin.id]) }
  let(:role_organizer) { Role.find_by(name: 'organizer', resource: conference) }
  let(:user_organizer) { create(:user, role_ids: [role_organizer.id]) }
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  shared_examples 'can access all actions' do
    describe 'GET #index' do
      it 'sets up users array with existing users records' do
        user1 = create(:user, email: 'user1@email.osem')
        user2 = create(:user, email: 'user2@email.osem')
        user_deleted = User.find_by(name: 'User deleted')
        get :index
        expect(assigns(:users)).to match_array([user_deleted, user, admin, user1, user2])
      end
      it 'renders index template' do
        get :index
        expect(response).to render_template :index
      end
    end
    describe 'PATCH #toggle_confirmation' do
      it 'confirms user' do
        user_to_confirm = create(:user, email: 'unconfirmed_user@osem.io', confirmed_at: nil)
        patch :toggle_confirmation, id: user_to_confirm.id, user: { to_confirm: 'true' }
        user_to_confirm.reload
        expect(user_to_confirm.confirmed?).to eq true
      end
      it 'undo confirmation of user' do
        patch :toggle_confirmation, id: user.id, user: { to_confirm: 'false' }
        user.reload
        expect(user.confirmed?).to eq false
      end
    end
    describe 'PATCH #update' do
      context 'valid attributes' do
        before do
          patch :update, id: user.id, user: attributes_for(:user, name: 'new name')
        end
  
        it 'locates requested @user' do
          expect(build(:user, id: user.id)).to eq(user)
        end
        it 'changes @users attributes' do
          user.reload
          expect(user.name).to eq('new name')
        end
        it 'redirects to the updated user' do
          expect(response).to redirect_to admin_users_path
        end
      end
    end
    describe 'GET #new' do
      it 'sets up a user instance for the form' do
        get :new
        expect(assigns(:user)).to be_instance_of(User)
      end
      it 'renders new user template' do
        get :new
        expect(response).to render_template :new
      end
    end
  
    describe 'POST #create' do
      context 'saves successfuly' do
        before do
          post :create, user: attributes_for(:user)
        end
  
        it 'redirects to admin users index path' do
          expect(response).to redirect_to admin_users_path
        end
  
        it 'shows success message in flash notice' do
          expect(flash[:notice]).to match('User successfully created.')
        end
  
        it 'creates new user' do
          expect(User.find(user.id)).to be_instance_of(User)
        end
      end
  
      context 'save fails' do
        before do
          allow_any_instance_of(User).to receive(:save).and_return(false)
          post :create, user: attributes_for(:user)
        end
  
        it 'renders new template' do
          expect(response).to render_template('new')
        end
  
        it 'shows error in flash message' do
          expect(flash[:error]).to match("Creating User failed: #{user.errors.full_messages.join('. ')}.")
        end
  
        it 'does not create new user' do
          expect do
            post :create, user: attributes_for(:user)
          end.not_to change{ Event.count }
        end
      end
    end
  end

  shared_examples 'does not have access to any action' do
    describe 'GET #index' do
      it 'render error and redirects to root page' do
        get :index
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
        expect(response).to redirect_to(root_path)
      end
    end
    describe 'PATCH #toggle_confirmation' do
      it 'render error and redirects to root page' do
        patch :toggle_confirmation, id: user.id, user: { to_confirm: 'false' }
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
        expect(response).to redirect_to(root_path)
      end
    end
    describe 'PATCH #update' do
      context 'valid attributes' do
        it 'render error and redirects to root page' do
          patch :update, id: user.id, user: attributes_for(:user)
          expect(flash[:alert]).to eq('You are not authorized to access this page.')
          expect(response).to redirect_to(root_path)
        end
      end
    end
    describe 'GET #new' do
      it 'render error and redirects to root page' do
        get :new
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
        expect(response).to redirect_to(root_path)
      end
    end
    
    describe 'POST #create' do
      it 'render error and redirects to root page' do
        post :create, user: attributes_for(:user)
        expect(flash[:alert]).to eq('You are not authorized to access this page.')
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context 'signed in as admin' do
    before do
      sign_in admin
    end

    it_behaves_like 'can access all actions'
  end

  context 'signed in with organization wide roles' do
    before do
      sign_in user_organization_admin
    end

    it_behaves_like 'does not have access to any action'
  end

  context 'signed in with conference wide roles' do
    before do
      sign_in user_organizer
    end
    it_behaves_like 'does not have access to any action'
  end
end
