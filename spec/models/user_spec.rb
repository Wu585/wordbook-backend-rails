require 'rails_helper'

RSpec.describe User, type: :model do
  it '有email' do
    user = User.new email: "frank@qq.com"
    expect(user.email).to eq 'frank@qq.com'
  end
end
