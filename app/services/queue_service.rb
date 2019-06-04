class QueueService

  def self.put_message_in_queue(audio_id)
    queue_url = ENV.fetch('CONTESTS_SQS_URL').to_s
    $sqs.send_message(queue_url: queue_url,
                      message_body: audio_id.to_s,
                      message_group_id: '1',
                      message_deduplication_id: audio_id.to_s)
  end
end