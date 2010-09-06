require 'digest/sha1'
require "#{RAILS_ROOT}/lib/exceptions"

class User < ActiveRecord::Base
  include Authenticatable
  attr_accessor  :secret_code
  attr_protected :id, :salt, :admin
  
  has_many :votes
  has_many :pezez, :through => :votes
  
  validates_length_of :identity, :within => 3..40
  validates_length_of :password, :within => 4..40
  validates_confirmation_of :password
  validates_presence_of :identity, :email, :password, :password_confirmation, :salt
  validates_uniqueness_of :identity, :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email"  
  
  def before_create
    raise SecretCodeError unless secret_code_checks_out
    true
  end
  
  def secret_code_checks_out
    Pez.first :conditions => ['status = ? AND identity = ? AND secret_code = ?', 'dispensed', identity, secret_code]
  end
  
  def dispenser
    Pez.all :conditions => { :status => 'seated' }
  end
  
  def liked pez
    with_preference_for(pez) { |vote| vote.approve ? 'liked' : '' }
  end
  
  def disliked pez
    with_preference_for(pez) { |vote| vote.approve ? '' : 'disliked' }
  end
  
  def with_preference_for pez
    vote = Vote.for(pez, self)
    return '' unless vote
    yield vote
  end

end
