require 'hashie'

class Project < ActiveRecord::Base
  attr_accessible :external_id, :external_source, :data, :active

  # validates :external_id, :uniqueness => true, :presence => true

  def details
    Hashie::Mash.new JSON.parse(data)
  end

  def self.active
    where(:active => true)
  end

  def self.fetch(limit=1)
    active.order("RANDOM()").limit(limit)
  end

  has_many :donations
end
