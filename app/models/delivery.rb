# queue of to-be-delivered items
# designed to stay empty, inbox-zero style, with completed deliveries stored separately

class Delivery
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :interest
  belongs_to :user
  
  # core fields needed to deliver the goods
  field :user_email
  field :subscription_type
  field :interest_in

  # if the user is not the owner of the main interest, there will be another
  # interest here, owned by the deliver's user, that the user saw the item "through"
  belongs_to :seen_through, class_name: "Interest"



  # store where this delivery should go out over email or sms
  # the delivery task should look at *this* field, so that we can
  # add the ability to override per-interest, per-subscription, whatever
  field :mechanism
  
  # item details
  field :item, :type => Hash, :default => {}
  
  index :subscription_type
  index :user_email
  index "item.date"
  index "item.item_id"
  index :interest_id
  index :user_id
  index :seen_through_id
  
  validates_presence_of :interest_id
  validates_presence_of :subscription_type
  validates_presence_of :interest_in
  validates_presence_of :user_id
  validates_presence_of :item


  # user and delivery mechanism decided in advance
  def self.schedule!(item, interest, subscription_type, seen_through, user, mechanism, email_frequency)
    create! :user_id => user.id,
      :user_email => user.email,
      :user_phone => user.phone,
      
      :subscription_type => subscription_type,
      
      :interest_in => interest.in,
      :interest => interest,

      :seen_through => seen_through,

      :mechanism => mechanism,
      :email_frequency => email_frequency,
      
      # drop the item into the delivery wholesale
      :item => item.attributes.dup
  end
end