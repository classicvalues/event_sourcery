RSpec.describe EventSourcery::EventStore::EventTypeSerializers::ClassName do
  subject(:serializer) { described_class.new }

  describe '#serialize' do
    it 'returns nil always when the class is Event' do
      expect(serializer.serialize(EventSourcery::Event)).to eq nil
    end

    it 'returns the serializer class name' do
      expect(serializer.serialize(ItemAdded)).to eq 'ItemAdded'
      expect(serializer.serialize(ItemRemoved)).to eq 'ItemRemoved'
    end
  end

  describe '#deserialize' do
    it 'looks up the constant' do
      expect(serializer.deserialize('ItemAdded')).to eq ItemAdded
      expect(serializer.deserialize('ItemRemoved')).to eq ItemRemoved
    end

    it 'returns Event when not found' do
      expect(serializer.deserialize('ItemStarred')).to eq EventSourcery::Event
    end
  end
end
