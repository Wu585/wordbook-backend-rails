require "rails_helper"

RSpec.describe User, :type => :model do
  before do
    User.create email: '1@qq.com'
  end

  example "用户表中不能有重复 email" do
    @other = User.create email: '1@qq.com'
    expect(@other.valid?).to eq(false)
    expect(@other.errors[:email][0]).to eq 'has already been taken'
  end
end