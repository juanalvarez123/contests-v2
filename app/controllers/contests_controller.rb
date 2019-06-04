class ContestsController < ApplicationController
  layout 'admin'

  # Default values
  @@limits_per_page = Array[5, 10, 20, 30, 40, 50]
  @@limit = @@limits_per_page[5]
  @@offset = 0

  def index
    if CacheService.has_active_session(session)
      @user = CacheService.get_session_user(session)

      # The limit and offset values are for pagination
      @limit = params[:limit].nil? ? @@limit : params[:limit]
      @offset = params[:offset].nil? ? @@offset : params[:offset]
      @limits_per_page = @@limits_per_page;

      base_query = Contest.all.where(user_id: @user.id)

      @contests = base_query
                      .limit(@limit.to_i)
                      .offset(@offset)
                      .order(created_at: :desc)

      quantity_of_pages_needed = (base_query.count.to_f / @limit.to_f).ceil
      calculate_pages(quantity_of_pages_needed)
    else
      redirect_to login_path
    end
  end

  def new
    if CacheService.has_active_session(session)
      @user = CacheService.get_session_user(session)
      @contest = Contest.new
    else
      redirect_to login_path
    end
  end

  def create
    if CacheService.has_active_session(session)
      @user = CacheService.get_session_user(session)
      @contest = Contest.new(contest_parameters)
      @contest.user_id = @user.id
      if !@contest.date_end.nil?
        @contest.date_end = @contest.date_end.change({ hour: 23, min: 59, sec: 59 })
      end
      if @contest.save
        attachment = params[:contest][:attachment]
        save_file(attachment)

        @contest.update_attribute(:url, get_host + params[:contest][:url_id])
        redirect_to @contest
      else
        render 'new'
      end
    else
      redirect_to login_path
    end
  end

  def show
    if CacheService.has_active_session(session)
      @user = CacheService.get_session_user(session)

      if Contest.where(_id: params[:id]).exists?
        @contest = Contest.find(params[:id])
        # The limit and offset values are for pagination
        @limit = params[:limit].nil? ? @@limit : params[:limit]
        @offset = params[:offset].nil? ? @@offset : params[:offset]
        @limits_per_page = @@limits_per_page;

        @audios = @contest.audios
                        .limit(@limit.to_i)
                        .offset(@offset)
                        .order(created_at: :desc)

        quantity_of_pages_needed = (@contest.audios.count.to_f / @limit.to_f).ceil
        calculate_pages(quantity_of_pages_needed)
      else
        render_page_not_found
      end
    else
      redirect_to login_path
    end
  end

  def edit
    if CacheService.has_active_session(session)
      @user = CacheService.get_session_user(session)
      @contest = Contest.find(params[:id])
    else
      redirect_to login_path
    end
  end

  def update
    @user = CacheService.get_session_user(session)
    @contest = Contest.find(params[:id])
    old_image_name = @contest.banner_image_name
    if @contest.update(contest_parameters)
      @contest.update_attribute(:date_end, @contest.date_end.change({ hour: 23, min: 59, sec: 59 }))
      # If there was a new image selected, then saves a new one and deletes the old one
      attachment = params[:contest][:attachment]
      if !attachment.nil?
        save_file(attachment)

        images_folder = ENV.fetch("CONTESTS_PATH_IMAGES").to_s + '/'
        FileSystemService.delete(old_image_name, images_folder)
      end

      @contest.update_attribute(:url, get_host + params[:contest][:url_id])
      redirect_to @contest
    else
      render 'edit'
    end
  end

  def destroy
    images_folder = ENV.fetch("CONTESTS_PATH_IMAGES").to_s + '/'
    original_audio_folder = ENV.fetch("CONTESTS_PATH_ORIGINAL_FILES").to_s + '/'
    converted_audio_folder = ENV.fetch("CONTESTS_PATH_CONVERTED_FILES").to_s + '/'

    @contest = Contest.find(params[:id])

    # Delete the contest image
    FileSystemService.delete(@contest.banner_image_name, images_folder)

    # Delete the audio records
    @contest.audios.each do |audio|
      audio.destroy

      # Delete audio files
      FileSystemService.delete(audio.original_name, original_audio_folder)
      if !audio.location_converted_audio.nil?
        FileSystemService.delete(audio.converted_name, converted_audio_folder)
      end
    end
    @contest.destroy
    redirect_to contests_path
  end

  def winner
    @contest = Contest.find(params[:id])
    audio = Audio.find(params[:winner_audio_id])

    @contest.update_attribute(:winner_audio_id, audio.id)
    redirect_to @contest
  end

  private def contest_parameters
    params.require(:contest).permit(:name, :date_init, :date_end, :prize_amount, :contest_text, :recommendations, :attachment, :url_id)
  end

  def get_host
    ENV.fetch("CONTESTS_SERVER_URL")
  end

  def get_nice_download_filename(audio, original)
    extension = File.extname(audio.original_name)
    if !original
      extension = File.extname(audio.converted_name)
    end

    audio.participant.first_name + ' concurso ' + audio.contest.id.to_s + extension
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

  # Save image in file system and update values in database
  private def save_file(attachment)
    extension = File.extname(attachment.original_filename)

    # Generate the file name with the extension
    file_name = @contest.id.to_s + "_" + Time.now.to_i.to_s + extension
    images_folder = ENV.fetch("CONTESTS_PATH_IMAGES").to_s + '/'

    # Save image in file system
    path = FileSystemService.save(attachment, file_name, images_folder)

    # Update values in database
    @contest.update_attribute(:banner_image_name, file_name)
    @contest.update_attribute(:location_banner_image, path)
  end

  def get_winner(contest)
    if contest.winner_audio_id.nil?
      return "Aún no hay un ganador"
    else
      audio = Audio.find(contest.winner_audio_id)
      return "Audio # " + audio.id.to_s + " enviado por " + audio.participant.first_name + " " + audio.participant.last_name
    end
  end

  def get_image_cloud_front_url(image_name)
    images_folder = ENV.fetch("CONTESTS_PATH_IMAGES").to_s + '/'
    return CdnService.generate_cloud_front_url(images_folder + image_name)
  end

  def get_original_audio_cloud_front_url(original_audio_name)
    original_audio_folder = ENV.fetch("CONTESTS_PATH_ORIGINAL_FILES").to_s + '/'
    return CdnService.generate_cloud_front_url(original_audio_folder + original_audio_name)
  end

  def get_converted_audio_cloud_front_url(converted_audio_name)
    converted_audio_folder = ENV.fetch("CONTESTS_PATH_CONVERTED_FILES").to_s + '/'
    return CdnService.generate_cloud_front_url(converted_audio_folder + converted_audio_name)
  end

  helper_method :get_host
  helper_method :get_nice_download_filename
  helper_method :get_winner
  helper_method :get_image_cloud_front_url
  helper_method :get_original_audio_cloud_front_url
  helper_method :get_converted_audio_cloud_front_url
end
