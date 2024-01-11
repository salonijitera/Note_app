
class PagesController < ApplicationController
    
    def index
        @pages = Page.all.select(:id, :name, :created_at, :updated_at)
    end
    
    def about
    end

end
