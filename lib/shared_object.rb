# Base object for sharing, subclass in STI for various types of object, e.g. link, wiki, blog post, comment etc.

class SharedObject < ActiveRecord::Base
 
  belongs_to :user
  acts_as_taggable
  
  include AASM
  
  aasm_column :state

  aasm_initial_state :shared
  aasm_state :draft
  aasm_state :shared
  
  aasm_event :share do
    transitions :to => :shared, :from => [:draft]
  end
  
  aasm_event :draft do
    transitions :to => :draft, :from => [:shared]
  end
  
end