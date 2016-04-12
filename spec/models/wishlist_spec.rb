require 'rails_helper'

RSpec.describe Wishlist, type: :model do
  describe 'create new wishlist' do
    it 'should have a flase value if no online value was given ' do
     @wishlist = FactoryGirl.create(:wishlist)
     @wishlist.valid?
     expect(@wishlist.online).to eq(false)
   end

   it 'should have a true value of online if you assign the true value to wishlist' do
    @wishlist = FactoryGirl.create(:wishlist)
    @wishlist.update(online: true)
    expect(@wishlist.online).to eq(true)
  end

  it 'should ordered by desc by desc scope' do
    FactoryGirl.create(:wishlist, title: 'first', created_at: 3.days.ago)
    FactoryGirl.create(:wishlist, title: 'second', created_at: 1.days.ago)
    expect(Wishlist.all.desc.pluck(:title)).to eq(['second', 'first'])
  end
 end
end
