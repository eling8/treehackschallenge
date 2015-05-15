class Person < ActiveRecord::Base
	validates :name, :presence => true
	validates :number, :presence => {:message => "Phone number required"}, :numericality => true, :length => {is: 10}
end