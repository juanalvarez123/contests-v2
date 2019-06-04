class Audio

  include Mongoid::Document
  include Mongoid::Timestamps

  field :original_name, type: String
  field :location_original_audio, type: String
  field :converted_name, type: String
  field :location_converted_audio, type: String
  field :status, type: String
  field :observations, type: String
  field :participant_id, type: BSON::ObjectId
  field :contest_id, type: BSON::ObjectId
  field :process_attempts, type: Numeric

  def participant
    Participant.all.where(_id: participant_id).first
  end

  def contest
    Contest.all.where(_id: contest_id).first
  end
end
