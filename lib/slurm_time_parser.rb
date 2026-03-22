# frozen_string_literal: true

# Provides parsing utilities for SLURM time formats.
module SlurmTimeParser
  class << self
    # Converts SLURM Elapsed string to hours (float).
    # Formats: DD-HH:MM:SS, HH:MM:SS, MM:SS, SS
    # Returns nil if string is invalid.
    def elapsed_to_hours(elapsed_str)
      return nil if elapsed_str.blank?

      # Basic validation: only digits, '-', ':' allowed
      return nil unless elapsed_str.match?(/\A[\d:-]+\z/)
      # Must contain at least one digit
      return nil unless elapsed_str.match?(/\d/)

      # Split by '-' for days
      if elapsed_str.include?('-')
        day_part, time_part = elapsed_str.split('-', 2)
        days = day_part.to_i
        hours, minutes, seconds = parse_elapsed_components(time_part)
      else
        days = 0
        hours, minutes, seconds = parse_elapsed_components(elapsed_str)
      end

      return nil if hours.nil? || minutes.nil? || seconds.nil?

      days * 24 + hours + minutes / 60.0 + seconds / 3600.0
    end

    # Parses time part formatted as HH:MM:SS or MM:SS or SS
    # Returns [hours, minutes, seconds] as integers, or [nil, nil, nil] if invalid.
    def parse_elapsed_components(time_str)
      parts = time_str.split(':').map(&:to_i)
      case parts.size
      when 3
        # HH:MM:SS
        [parts[0], parts[1], parts[2]]
      when 2
        # MM:SS
        [0, parts[0], parts[1]]
      when 1
        # SS
        [0, 0, parts[0]]
      else
        [nil, nil, nil]
      end
    end

    # Parses a SLURM timestamp string (Start or End) into a Time object.
    # Format: "YYYY-MM-DDTHH:MM:SS" or "YYYY-MM-DD HH:MM:SS" or "Unknown"
    # Returns nil if string is blank or "Unknown".
    def parse_time_string(time_str)
      return nil if time_str.blank? || time_str == 'Unknown'

      # Try ISO 8601 with 'T'
      begin
        Time.zone.parse(time_str.gsub(' ', 'T'))
      rescue StandardError
        nil
      end
    end
  end
end
