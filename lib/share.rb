class Share < ActiveRecord::Base
  belongs_to :shareable, :polymorphic => true
  belongs_to :shared_to, :polymorphic => true
  belongs_to :user
  
  # Add state to sharings for editorial and management purposes
  include AASM
  
  aasm_column :state
  # Determine whether the sharing is initiated by 'self', i.e. staging objects to personal space purposes
  aasm_initial_state Proc.new { |share| (share.own_shared_to? or share.member_of_shared_to? ) ? :published : :pending }
  
  aasm_state :pending
 # aasm_state :published, :enter => :set_published_date
  aasm_state :published
  
  aasm_event :publish do
    transitions :to => :published, :from => [:pending]
  end
  
  def self.find_shares_by_user(user)
    find(:all,
      :conditions => ["user_id = ?", user.id],
      :order => "created_at DESC"
    )
  end
  
  def self.find_by_shared_to(object)
    to = ActiveRecord::Base.send(:class_name_of_active_record_descendant, object.class).to_s
    find(:all, :conditions=>["shared_to_type=? and shared_to_id=?", to, object.id])
  end
  
  def self.find_by_shareable_and_shared_to(shareable, object)
    share = ActiveRecord::Base.send(:class_name_of_active_record_descendant, shareable.class).to_s
    to = ActiveRecord::Base.send(:class_name_of_active_record_descendant, object.class).to_s
    Share.find(:all, :conditions=>["shareable_type = ? and shareable_id = ? and shared_to_type = ? and shared_to_id = ?",
                    share, shareable.id, to, object.id])
  end
  
  def self.find_by_shareable_type_and_id(shareable_type, shareable_id)
     shared = eval(shareable_type).find(shareable_id)
    return shared
  end
  
  def set_published_date
   # self.published_at = DateTime.now
  end
  
  # Need to determine whether the share is initiated by the owner of the group -
  # in this case the sharing is published automatically 
  def own_shared_to?
    shared_to = self.shared_to_type.constantize.find(self.shared_to_id)
    shared_to.user_id == self.user_id ? true : false
  end
  
  # Need to determine whether the share is initiated by a member of the group -
  # in this case the sharing is published automatically
  def member_of_shared_to?  
    shared_to = self.shared_to_type.constantize.find(self.shared_to_id)
    User.find(self.user_id).groups.include?(shared_to) ? true : false
  end
  
end