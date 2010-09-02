
require "#{RAILS_ROOT}/lib/extensions/string"

module UsersHelper
  
  def yes_no
    @approve ? 'yes' : 'no'
  end
  
  def new_candy
    session[:user].unvoted_candy
  end
  
  def vote_link pez, yes_or_no
    pez.votable? ? active_vote_link(pez, yes_or_no) : yes_or_no
  end
  
  def active_vote_link pez, yes_or_no
    link_to yes_or_no, :controller => 'users', :action => 'vote', :pez_id => pez.id, :approve => yes_or_no.to_boolean
  end
  
end