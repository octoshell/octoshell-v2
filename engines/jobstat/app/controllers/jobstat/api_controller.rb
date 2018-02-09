#require_dependency "jobstat/application_controller"

module Jobstat
  class ApiController < ActionController::Base

    before_filter :parse_request, :authenticate_from_token!, only: [:push]

    @@data_types={}

    def push
      # push new data
      answer=[]
      count=0
      if data=@json['data']
        if data.class != Array
          answer << "Bad data. Expected array, got '#{data.class}'"
        else
          a,c=push_data(data)
          answer.append a
          count+=c
        end
      end
      if data=@json['digestdata']
        if data.class != Array
          answer << "Bad data. Expected array, got '#{data.class}'"
        else
          a,c=push_digest_data(data)
          answer.append a
          count+=c
        end
      end
      if data=@json['job']
        if data.class != Array
          answer << "Bad data. Expected array, got '#{data.class}'"
        else
          a,c=push_job(data)
          answer.append a
          count+=c
        end
      end
      answer<<"Saved: #{count}"
      render text: answer.to_json, status: (answer.size==1 ? :ok : :multi_status)
    end

    def push_data data
      answer=[]
      count=0
      data.each do |item|
        name=item['name']

        type=if @@data_types[name].nil?
          Jobstat::DataType.take(name: name)
        else
          @@data_types[name]
        end

        d=case type
        when 's' #string
          Jobstat::StringDatum.create item
        when 'f' #float
          Jobstat::FloatDatum.create item
        else
          nil
        end

        if d.nil?
          answer<<"Bad type '#{name}'."
        else
          if d.save
            count+=1
          else
            answer<<"Cannot save: #{d.errors.full_messages}"
          end
        end
      end
    end

    def push_digest_data data
      answer=[]
      count=0
      data.each do |item|
        name=item['name']

        type=if @@data_types[name].nil?
          Jobstat::DataType.take(name: name)
        else
          @@data_types[name]
        end

        d=case type
        when 's' #string
          Jobstat::DigestStringDatum.create item
        when 'f' #float
          Jobstat::DigestFloatDatum.create item
        else
          nil
        end

        if d.nil?
          answer<<"Bad type '#{name}'."
        else
          if d.save
            count+=1
          else
            answer<<"Cannot save: #{d.errors.full_messages}"
          end
        end
      end
    end

    def push_job_data data
      answer=[]
      count=0
      data.each do |item|
        d=Jobstat::JobDatum.create item

        if d.save
          count+=1
        else
          answer<<"Cannot save: #{d.errors.full_messages}"
        end
      end
    end

    protected

    def authenticate_from_token!
      if !@json['api_token']
        render nothing: true, status: :forbidden
      end
      @json.delete['api_token']
    end

    def parse_request
      @json = JSON.parse(request.body.read)
    end
  end
end
