class Video < ActiveRecord::Base
  require 'youtube_it'
  require 'friendly_id'
  belongs_to :resource, :polymorphic => true
 # before_validation :get_datas
  #validates_presence_of :source_url, :title, :thumbnail_url
  
  
#  validates :title,
#        :length => { :minimum => 2, :maximum => 200},
#        :presence => {:message => "can't be blank"}
 # validates :year, :numericality => true, :length => { :minimum => 4, :maximum=>4 }, :allow_blank=>true

#  validates_inclusion_of :year, :in => 1900..2020, :allow_blank=>true, :allow_nil=>true
  #validates :source_url, :presence => {:message => "can't be blank"}
  #validates :thumbnail_url, :presence => {:message => "can't be blank"}
  
  validates_presence_of :source_url, :title, :thumbnail_url, :videotype_id
  validates_length_of :title, :within => 2..200
  
  
  has_friendly_id :url_name, :use_slug => true  
  rateable_attributes :sound, :picture, :originality,:quality, :range => 1..5
#  validates :videotype_id, :presence => true, :on=>:create
  
  belongs_to :videotype
  


  def url_name
    "#{artist} #{title}"
  end
  
   def next
        v= self.class.find :first, :conditions => ["id > ?",self.id], :order => "id ASC"
        v= self.class.first if v.nil?
        return v
      end

      def previous
        v= self.class.find :first, :conditions => ["id < ?",self.id],:order => "id DESC"
        v= self.class.last if v.nil?
        return v
      end


      def self.random_id
         offset = rand(self.count)
         return self.first(:offset => offset).id
         #self.find(rand(self.count)).id      
      end

    def self.search(search)
      if search
        where('title LIKE ?', "%#{search}%")
      else
        scoped
      end
    end
    
    def self.year_range
      ret=[]
      ar=(1950..Time.now.strftime("%Y").to_i).to_a.reverse
      ar.each do |a|
        ret<<[a,a]
      end
      return ret
    end

    def ttip
  #    "<span class='big'>#{title}</span><hr /><strong>#{artist}</strong><i>#{year}</i><br />#{description}"
      "#{title} :: #{provider} ::: #{description}"
      #{}"<span class='ttip_header'>#{title}</span><span class='ttip_content'>#{artist} :: #{year}</span><span class='ttip_content'>#{provider}</span>"
    end

    # def self.random
    #   self.where(rand(self.count))
    # end


     def get_datas
       tnurl="/images/no-image.jpg"
       if self.source_url.match(/(youtube.com*)/)
         vid=set_youtube_url(self.source_url)
       #  vid=self.source_url.match(/=([A-Za-z0-9]*)/) ? self.source_url.match(/=([A-Za-z0-9\d_\-]*)/)[0].gsub(/=/,'') : self.source_url
         unless vid.blank?
           
             client=YouTubeIt::Client.new(:dev_key => APP_CONFIG[:youtube_api_key] )
     
       
             begin
               youtube_data=client.video_by(vid)
             rescue
               youtube_data=nil
               self.errors.add(:source_url,  "Invalid video url, removed from youtube")
               self.source_url=nil
             end 
             
             
             unless youtube_data.nil?   
               self.title= self.title.blank? ? youtube_data.title : self.title
               self.description= self.description.blank? ? youtube_data.description  : self.description
               tnurl=youtube_data.thumbnails[0].url
               self.media_content_url=youtube_data.media_content[0].url
              end
          end
          self.provider="youtube"
       elsif self.source_url.match(/(vimeo.com*)/)
          tnurl='/images/video/vimeo.png' 
          vid=self.source_url.match(/vimeo.com\/([^&]+)/)[1]
          unless vid.blank?
            vimeo_data=Vimeo::Simple::Video.info(vid)
            if vimeo_data && vimeo_data.size>0
              tnurl=vimeo_data[0]["thumbnail_medium"]
              self.title= self.title.blank? ? vimeo_data[0]["title"] : self.title
              self.description= self.description.blank? ? vimeo_data[0]["description"] : self.description
            end
          end

         #self.media_content_url="/videos/#{self.id}"


         self.media_content_url="http://www.vimeo.com/moogaloop.swf?clip_id=#{vid}&amp;server=www.vimeo.com&amp;fullscreen=1&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color="
         self.provider="vimeo"
      elsif self.source_url.match(/(dailymotion.com*)/)
         self.provider="dailymotion"      
         tnurl='/images/video/dailymotion.png' 
      elsif self.source_url.match(/(myspace.com*)/)
         self.provider="myspace"      
          tnurl='/images/video/myspace.png' 
      end

       self.thumbnail_url=tnurl


      end
      
      
      def self.get_provider_datas(source_url)
        return nil if source_url.nil?
         tnurl="/images/no-image.jpg"
         h={}
         
         
         
         if source_url.match(/(youtube.com*)/) || source_url.match(/(youtu.be*)/)
           
           if source_url.match(/(youtu.be*)/)
             vid=set_new_youtube_url(source_url)
           else
             vid=set_youtube_url(source_url)
           end
       #    vid=source_url.match(/=([A-Za-z0-9]*)/) ? source_url.match(/=([A-Za-z0-9\d_\-]*)/)[0].gsub(/=/,'') : source_url
           unless vid.blank?

               client=YouTubeIt::Client.new(:dev_key => APP_CONFIG[:youtube_api_key] )


               begin
                 youtube_data=client.video_by(vid)
               rescue
                 return nil
               end 


               unless youtube_data.nil?   
                 h["title"]= youtube_data.title 
                 h["description"]= youtube_data.description 
                 h["tnurl"]=youtube_data.thumbnails[0].url
                 h["media_content_url"]=youtube_data.media_content[0].url
                end
            end
            h["provider"]="youtube"
         elsif source_url.match(/(vimeo.com*)/)
            tnurl='/images/video/vimeo.png' 
            vid=source_url.match(/vimeo.com\/([^&]+)/)[1]
            unless vid.blank?
              vimeo_data=Vimeo::Simple::Video.info(vid)
              if vimeo_data && vimeo_data.size>0
                 h["tnurl"]=vimeo_data[0]["thumbnail_medium"]
                 h["title"]= vimeo_data[0]["title"] 
                 h["description"]= vimeo_data[0]["description"] 
              end
            end

         


            h["media_content_url"]="http://www.vimeo.com/moogaloop.swf?clip_id=#{vid}&amp;server=www.vimeo.com&amp;fullscreen=1&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color="
            h["provider"]="vimeo"
            
            
        elsif source_url.match(/(dailymotion.com*)/)
            h["provider"]="dailymotion"      
            h["tnurl"]='/images/video/dailymotion.png' 
        elsif source_url.match(/(myspace.com*)/)
            h["provider"]="myspace"      
            h["tnurl"]='/images/video/myspace.png' 
        end
        
        return h
      
      end
      
      def self.set_new_youtube_url(source_url)
        source_url.match(/youtu.be\/([A-Za-z\d_\-\.+]+)/) ? source_url.match(/youtu.be\/([A-Za-z\d_\-\.+]+)/)[1] : source_url
      end
      def self.set_youtube_url(source_url)
        source_url.match(/=([A-Za-z0-9]*)/) ? source_url.match(/=([A-Za-z0-9\d_\-]*)/)[0].gsub(/=/,'') : source_url        
      end
end


