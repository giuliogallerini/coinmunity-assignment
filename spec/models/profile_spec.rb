require 'rails_helper'

RSpec.describe Profile, type: :model do

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:picture)}
  end

  describe "associations" do
    describe "association with user" do
      it { is_expected.to belong_to(:user) }
    end
  end

end
