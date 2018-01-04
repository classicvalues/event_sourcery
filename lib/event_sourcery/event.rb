module EventSourcery
  # Represents an Event
  class Event
    include Comparable

    # Event type
    #
    # Will return `nil` if called on an instance of {EventSourcery::Event}.
    def self.type
      unless self == Event
        EventSourcery.config.event_type_serializer.serialize(self)
      end
    end

    attr_reader :id, :uuid, :aggregate_id, :type, :body, :version, :created_at, :correlation_id, :causation_id

    # @!attribute [r] id
    # @return [Integer] unique identifier at the persistent layer

    # @!attribute [r] uuid
    # @return [String] unique identifier (UUID) for this event.

    # @!attribute [r] aggregate_id
    # @return [String] aggregate instance UUID to which this event belongs to.

    # @!attribute [r] type
    # @return event type

    # @!attribute [r] body
    # @return [Hash] Content of the event body.

    # @!attribute [r] version
    # @return [String] event version. Used by some event stores to guard against concurrency errors.

    # @!attribute [r] created_at
    # @return [Time] Created at timestamp (in UTC) for the event.

    # @!attribute [r] correlation_id
    # @return [String] UUID attached to the event that allows reference to a particular transaction or event chain. This value is often supplied as part of a command issued by clients.

    # @!attribute [r] causation_id
    # @return [String] UUID of the event that caused this event.

    #
    # @param id [Integer] Optional. Unique identifier at the persistent layer. By default this will be set by the underlying persistence layer when persisting the event.
    # @param uuid [String] UUID as a string. Optional. Unique identifier for this event. A random UUID will be generated by default.
    # @param aggregate_id [String] UUID as a string. Aggregate instance UUID to which this event belongs to.
    # @param type [Class] Optional. Event type. {Event.type} will be used by default.
    # @param version [String] Optional. Event's aggregate version. Used by some event stores to guard against concurrency errors.
    # @param created_at [Time] Optional. Created at timestamp (in UTC) for the event.
    # @param correlation_id [String] Optional. UUID attached to the event that allows reference to a particular transaction or event chain. This value is often supplied as part of a command issued by clients.
    # @param causation_id [String] Optional. UUID of the event that caused this event.
    def initialize(id: nil,
                   uuid: SecureRandom.uuid,
                   aggregate_id: nil,
                   type: nil,
                   body: nil,
                   version: nil,
                   created_at: nil,
                   correlation_id: nil,
                   causation_id: nil)
      @id = id
      @uuid = uuid && uuid.downcase
      @aggregate_id = aggregate_id && aggregate_id.to_str
      @type = self.class.type || type.to_s
      @body = body ? EventSourcery::EventBodySerializer.serialize(body) : {}
      @version = version ? Integer(version) : nil
      @created_at = created_at
      @correlation_id = correlation_id
      @causation_id = causation_id
    end

    # Is this event persisted?
    def persisted?
      !id.nil?
    end

    def hash
      [self.class, uuid].hash
    end

    def eql?(other)
      instance_of?(other.class) && uuid.eql?(other.uuid)
    end

    def <=>(other)
      id <=> other.id if other.is_a? Event
    end

    # create a new event identical to the old event except for the provided changes
    #
    # @param attributes [Hash]
    # @return Event
    # @example
    #     old_event = EventSourcery::Event.new(type: "item_added", causation_id: nil)
    #     new_event = old_event.with(causation_id: "05781bd6-796a-4a58-8573-b109f683fd99")
    #
    #     new_event.type # => "item_added"
    #     new_event.causation_id # => "05781bd6-796a-4a58-8573-b109f683fd99"
    #
    #     old_event.type # => "item_added"
    #     old_event.causation_id # => nil
    #
    #     # Of course, with can accept any number of event attributes:
    #
    #     new_event = old_event.with(id: 42, version: 77, body: { 'attr' => 'value' })
    #
    #     # When using typed events you can also override the event class:
    #
    #     new_event = old_event.with(event_class: ItemRemoved)
    #     new_event.type # => "item_removed"
    #     new_event.class # => ItemRemoved
    def with(event_class: self.class, **attributes)
      if self.class != Event && !attributes[:type].nil? && attributes[:type] != type
        raise Error, 'When using typed events change the type by changing the event class.'
      end

      event_class.new(**to_h.merge!(attributes))
    end

    # returns a hash of the event attributes
    #
    # @return Hash
    def to_h
      {
        id:             id,
        uuid:           uuid,
        aggregate_id:   aggregate_id,
        type:           type,
        body:           body,
        version:        version,
        created_at:     created_at,
        correlation_id: correlation_id,
        causation_id:   causation_id,
      }
    end
  end
end
