class VoicesController < ApplicationController
  layout 'participant'

  # Default values
  @@limits_per_page = Array[5, 10, 20]
  @@limit = @@limits_per_page[2]
  @@offset = 0

  @@success_message = "Hemos recibido tu voz y la estamos procesando para que sea publicada en la página del "+
      "concurso y pueda ser posteriormente revisada por nuestro equipo de trabajo. Tan pronto la voz quede " +
      "publicada en la página del concurso te notificaremos por email."

  def new
    if Contest.where(url_id: params[:url_id]).exists?
      @contest = Contest.find_by(url_id: params[:url_id])
      @participant = Participant.new
      @success_message = nil
      generate_pagination
    else
      render_page_not_found
    end
  end

  def new_by_id
    if Contest.where(id: params[:id]).exists?
      contest = Contest.find(params[:id])
      redirect_to contest.url
    else
      render_page_not_found
    end
  end

  def create
    @contest = Contest.find(params[:id])

    # Validate it first
    @participant = Participant.new(participant_parameters)
    if @participant.valid?
      @participant = Participant.all.where(email: params[:participant][:email]).first
      audio_id = 0

      if @participant
        # There is a participant registered with the same email, then just saves the audio
        audio_id = save_audio(@participant, @contest, params)
      else
        # There is no participant with that email, then create the participant and saves the audio
        @participant = Participant.new(participant_parameters)
        @participant.save
        audio_id = save_audio(@participant, @contest, params)
      end

      # Put a message in the AWS SQS
      QueueService.put_message_in_queue(audio_id)

      @success_message = @@success_message
    end

    generate_pagination
    render 'new'
  end

  private def participant_parameters
    params.require(:participant).permit(:first_name, :last_name, :email, :observations, :attachment)
  end

  # Create a new record in audios table, next calls the FileSystemService.save method to save the audio in the file system
  # Also returns the audio.id
  private def save_audio(participant, contest, params)
    # Get the extension
    attachment = params[:participant][:attachment]
    extension = File.extname(attachment.original_filename)

    audio = Audio.new
    audio.status = ContestStatusService.IN_PROGRESS
    audio.participant_id = participant.id
    audio.contest_id = contest.id
    audio.observations = params[:participant][:observations]
    audio.process_attempts = 0
    audio.save

    # Generate the file name with the extension
    file_name = audio.id.to_s + "_" + Time.now.to_i.to_s + extension

    # Save the audio file
    audio_folder = ENV.fetch("CONTESTS_PATH_ORIGINAL_FILES").to_s + '/'
    path = FileSystemService.save(attachment, file_name, audio_folder)

    audio.update_attribute(:original_name, file_name)
    audio.update_attribute(:location_original_audio, path)

    return audio.id
  end

  private def generate_pagination
    # The limit and offset values are for pagination
    @limit = params[:limit].nil? ? @@limit : params[:limit]
    @offset = params[:offset].nil? ? @@offset : params[:offset]
    @limits_per_page = @@limits_per_page;

    base_query = @contest.audios.where(status: ContestStatusService.CONVERTED)

    @audios = base_query
                  .limit(@limit.to_i)
                  .offset(@offset)
                  .order(created_at: :desc)

    quantity_of_pages_needed = (base_query.count.to_f / @limit.to_f).ceil
    calculate_pages(quantity_of_pages_needed)
  end

  private def calculate_pages(quantity_of_pages_needed)
    @pages = Array[]
    page = 1
    while quantity_of_pages_needed >= page
      @pages.push(page)
      page += 1
    end

    if quantity_of_pages_needed == 1
      @pages = Array[]
    end

    @current_page = (@offset.to_f / @limit.to_f).round + 1
  end

  # The contest date end is calculated aginst UTC time
  def is_contest_finished(contest)
    return contest.date_end > DateTime.now.new_offset(0)
  end

  def get_image_cloud_front_url(image_name)
    images_folder = ENV.fetch("CONTESTS_PATH_IMAGES").to_s + '/'
    return CdnService.generate_cloud_front_url(images_folder + image_name)
  end

  def get_converted_audio_cloud_front_url(converted_audio_name)
    converted_audio_folder = ENV.fetch("CONTESTS_PATH_CONVERTED_FILES").to_s + '/'
    return CdnService.generate_cloud_front_url(converted_audio_folder + converted_audio_name)
  end

  helper_method :is_contest_finished
  helper_method :get_image_cloud_front_url
  helper_method :get_converted_audio_cloud_front_url
end
