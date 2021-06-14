describe FranceConnect::ParticulierController, type: :controller do
  describe '#auth' do
    subject { get :login }

    it { is_expected.to have_http_status(:redirect) }
  end

  describe '#callback' do
    let(:france_connect_service) { instance_double("FranceConnectService") }

    context 'when params are missing' do
      subject { get :callback }

      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'when param code is missing' do
      subject { get :callback, params: { code: nil } }

      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'when param code is empty' do
      subject { get :callback, params: { code: "" } }

      it { is_expected.to redirect_to(new_user_session_path) }
    end

    context 'when code is correct' do
      let(:code) { "2401d211-67df-43a0-9d9d-4ec0e01be3f2" }

      subject { get :callback, params: { code: code } }

      before do
        expect(FranceConnectService).to receive(:new).with(code: code).and_return france_connect_service
        expect(france_connect_service).to receive(:find_or_retrieve_france_connect_information).and_return fci
      end

      context 'when france_connect_particulier_id exist in database' do
        let!(:fci) { create(:france_connect_information, :with_user) }
        let(:user) { fci.user }

        context do
          before do
            subject
          end

          it { expect { response }.not_to change { FranceConnectInformation.count } }
          it { expect(user.reload).to be_france_connect_particulier }
          it { expect(user.reload.can_france_connect?).to be true }
        end

        context 'and the user has a stored location' do
          let(:stored_location) { '/plip/plop' }

          before do
            controller.store_location_for(:user, stored_location)
            subject
          end

          it { is_expected.to redirect_to(stored_location) }
        end

        context 'and the user is also instructeur' do
          before do
            create(:instructeur, email: user.email)
            user.reload
            subject
          end

          it { expect(user).to be_instructeur }
          it { is_expected.to redirect_to(new_user_session_path) }
          it { expect(flash[:alert]).to be_present }
        end
      end

      context 'when france_connect_particulier_id does not exist in database' do
        let(:fci) { build(:france_connect_information, :with_user) }

        context do
          let(:stored_fci) { FranceConnectInformation.last }

          before do
            subject
          end

          it { expect(stored_fci).to have_attributes(fci.attributes.except("created_at", "updated_at")) }
          it { is_expected.to redirect_to(root_path) }
        end

        it { expect { subject }.to change { FranceConnectInformation.count }.by(1) }
      end
    end

    context 'when code is not correct' do
      let(:code) { "invalid" }

      subject { get :callback, params: { code: code } }

      before do
        expect(FranceConnectService).to receive(:new).with(code: code).and_return france_connect_service

        expect(france_connect_service).to receive(:find_or_retrieve_france_connect_information) do
          raise Rack::OAuth2::Client::Error.new(500, error: "Internal Error")
        end

        subject
      end

      it { is_expected.to redirect_to(new_user_session_path) }
      it { expect(flash[:alert]).to be_present }
    end
  end
end
