require 'open3'

module Wikiplus  
  class ImageUploader < CarrierWave::Uploader::Base
    storage :file
    include CarrierWave::MiniMagick
    OTHER_PREVIEW = Rails.root.join('engines/wikiplus/lib/def_preview.png')

    def content_type_whitelist
      /(image|video|application)\//
    end

    def store_dir
      "images/wikiplus/pictures/"
    end

    version :thumb do
      process resize_to_fit: [192,192], if: :image?
      #process thumbnail: [{format: 'jpg', quality: 10, size: 192, strip: false, logger: Rails.logger}], if: :video?
      process video_thumb: [], if: :video?
      process just_image: [], if: :other?
    end

    version :mp4 do
      process encode_video: [:mp4], if: :video?
      def full_filename (for_file = model.logo.file) 
        "#{for_file}_enc.mp4"
      end
    end

    version :webm do
      process encode_video: [:webm], if: :video?
      def full_filename (for_file = model.logo.file) 
        "#{for_file}_enc.webm"
      end
    end

    def just_image opts=nil
      #format = 'png'
      FileUtils.cp(OTHER_PREVIEW,current_path)
    end

    def video_thumbnailer
      @ffmpegthumbnailer.nil? ? 'ffmpegthumbnailer'.freeze : @ffmpegthumbnailer
    end

    def video_thumb
      format = 'jpg'
      tmp_path = File.join( File.dirname(current_path), "tmpfile.#{format}" )
      options = '-f -w'
      cmd = %Q{#{video_thumbnailer} -i "#{current_path.shellescape}" -o "#{tmp_path.shellescape}" #{options}}.rstrip

      exit_code = run_cmd(cmd)

      if exit_code != 0
        logger.warn "Cannot thumbnail video #{current_path}:"
        outputs.each{ |l|
          logger.warn "   > #{l.chomp}"
        }
      else
         File.rename tmp_path, current_path
         self.file.instance_variable_set(:@content_type, "image/jpeg")
      end
    end

    def image? f
      f.content_type.include? 'image'
    end

    def is_image?
      image? file
    end

    def video? f
      f.content_type.include?('video') ||
      f.content_type.include?('mp4') ||
      f.content_type.include?('webm')
    end

    def is_video?
      video? file
    end

    def other? f
      not (image?(f) || video?(f))
    end

    def is_other?
      other? file
    end

    def encode_video(format=:webm)
      tmpf = tmp_filename(current_path, format)

      code = convert_video(current_path,tmpf)
      Rails.logger.warn "Encoded to #{tmpf} from #{current_path} (#{code}) #{self.inspect}"
      File.rename(tmpf, current_path)

      tmpf
    end

    def cont_type
      file.content_type
    end

    private

    def run_cmd cmd
      outputs = []
      exit_code = nil

      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        stderr.each("r") do |line|
          outputs << line
        end
        exit_code = wait_thr.value
      end
      exit_code
    end

    def ffmpeg
      'ffmpeg'
    end

    def convert_video src, dest, options=''
      cmd = %Q(#{ffmpeg} -y -i '#{src}' #{options} '#{dest}')
      Rails.logger.warn "convert_video: '#{cmd}'"
      run_cmd cmd
    end

    def tmp_filename source, format, prefix: nil
      ext = File.extname(source)
      source_filename_without_ext = File.basename(source, ext)
      File.join File.dirname(source), "tmp#{prefix.present? ? '_' + prefix : ''}_#{source_filename_without_ext}_#{Time.now.to_i}.#{format}"
    end
  end
end