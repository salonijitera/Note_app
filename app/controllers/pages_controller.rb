class PagesController < ApplicationController
    
    def index
        @pages = Page.all.select(:id, :name, :created_at, :updated_at)
    end
    
    def about
      @about_content = Page.find_by(name: 'about')&.content
    end

end
