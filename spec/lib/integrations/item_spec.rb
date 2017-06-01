require "rails_helper"

describe Integrations::Item do
  before do
    @item = Integrations::Item
  end

  describe 'initializer' do
    it 'should create instance variables from parameters' do
      params = {local_id: 1, integration_id: 2, price: 10.5, image_urls: ['a', 'b'], title: 'title', description: 'desc'}
      item_obj = @item.new(params)
      expect(item_obj.local_id).to eq(1)
      expect(item_obj.integration_id).to eq(2)
      expect(item_obj.price).to eq(10.5)
      expect(item_obj.image_urls).to eq(['a', 'b'])
      expect(item_obj.title).to eq('title')
      expect(item_obj.description).to eq('desc')
    end
  end

  describe 'to_hash method' do
    it 'should return correct hash keys' do
      expect(@item.new.to_hash.keys).to eq(%w(local_id integration_id price image_urls title description))
    end
  end

end