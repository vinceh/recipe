require 'rails_helper'

RSpec.describe JwtDenylist, type: :model do
  describe 'validations' do
    describe 'jti presence' do
      it 'requires jti to be present (AC-MODEL-JWT-001)' do
        denylist = build(:jwt_denylist, jti: nil)
        expect(denylist).not_to be_valid
        expect(denylist.errors[:jti]).to include("can't be blank")
      end
    end

    describe 'jti uniqueness' do
      it 'enforces jti uniqueness (AC-MODEL-JWT-002)' do
        create(:jwt_denylist, jti: 'abc123def456')
        duplicate = build(:jwt_denylist, jti: 'abc123def456')
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:jti]).to include('has already been taken')
      end
    end
  end
end
