class Videotype < ActiveRecord::Base
  has_many :videos
  
  def self.form_list
    r=[]
    self.all.each do |vt|
      sy="#{vt.name}".to_sym
      r<<[sy,vt.id]
    end
    return r
  end
  
  def self.inline_form_list
    r=[]
    self.all.each do |vt|
      sy="#{vt.name}".to_sym
      r<<[vt.id,sy]
    end
    return r
  end
end