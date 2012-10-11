require "active_record"
require "active_record/version"
require "action_view"
require "digest/sha1"

$LOAD_PATH.unshift(File.dirname(__FILE__))

module Yabo
  module Acts #:nodoc:
    module Videoclub #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_videoclub
          has_many :videos, :as => :resource, :dependent => :destroy

          include LinkingPaths::Acts::Videoclub::InstanceMethods
          #extend LinkingPaths::Acts::Videoclub::SingletonMethods
        end
      end

      # Adds instance methods.
      module InstanceMethods
        def has_videos?
          self.videos.size > 0
        end

      end
    end
  end
end


require "video"
require "videotype"
require "videoclub_helper"
$LOAD_PATH.shift



if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Yabo::Acts::Videoclub
  ActiveRecord::Base.send :include, Yabo::Acts::Videoclub
end

if defined?(ActionView::Base)
  ActionView::Base.send :include, Yabo::Acts::Videoclub::Helper
end



ActiveRecord::Base.send :include, LinkingPaths::Acts::Videoclub
ActionView::Base.send :include, LinkingPaths::Videoclub::Helper