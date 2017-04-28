module EventSourcery
  class Event

    def self.type
      unless self == Event
        EventSourcery.config.event_type_serializer.serialize(self)
      end
    end

    attr_reader :id, :uuid, :aggregate_id, :type, :body, :version, :created_at

    def initialize(id: nil,
                   uuid: SecureRandom.uuid,
                   aggregate_id: nil,
                   type: nil,
                   body: nil,
                   version: nil,
                   created_at: nil)
      @id = id
      @uuid = uuid
      @aggregate_id = aggregate_id
      @type = self.class.type || type.to_s
      @body = body ? EventSourcery::EventBodySerializer.serialize(body) : {}
      @version = version ? Integer(version) : nil
      @created_at = created_at
    end

    def persisted?
      !id.nil?
    end
  end
end
