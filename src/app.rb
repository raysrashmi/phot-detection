require 'json'
require 'base64'
require "aws-record"
require "aws-sdk-rekognition"

class RekognitionModel
  include Aws::Record
  set_table_name ENV['TABLE_NAME']
  string_attr :id, hash_key: true
  string_attr :body_text

end


def lambda_handler(event:, context:)
  bucket = event['Records'][0]['s3']['bucket']['name']

  key = event['Records'][0]['s3']['object']['key']
  puts key
  puts bucket
  text_detections = detect_text(bucket, key).text_detections

  puts text_detections

  para = (text_detections.map{ |h| h["detected_text"] }).join(" ")
  item = RekognitionModel.new(id: SecureRandom.uuid, body_text: para)
  item.save! # raise an exception if save fails
  item.to_h
end

def rekognition_client
    @rekognition_client ||= Aws::Rekognition::Client.new
end

def detect_text(bucket, key)
  rekognition_client.detect_text(image: { s3_object: { bucket: bucket, "name": key } })
end
