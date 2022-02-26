class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      redirect_page = false
      if params[:sort_column]
        # new sort column was set by user
        # save in session
          session[:sort_column] = params[:sort_column]
      elsif session[:sort_column]
        # previous session had user sort by movie title or release date
          redirect_page = true
          params[:sort_column] = session[:sort_column]
      end
  
      @all_ratings = Movie.uniq.pluck(:rating)
      if params[:ratings]
        # new ratings selected by user
        # save in session
          session[:ratings] = params[:ratings]
      elsif session[:ratings]
         # previous session had user select filter by movie ratings
          redirect_page = true
          params[:ratings] = session[:ratings]
      end
  
      if session[:ratings] != nil
        # get rating selected from current or previous session
          @ratings_selected = session[:ratings].keys
      else
        # if no rating filter, all ratings
          @ratings_selected = @all_ratings
      end
  
      if redirect_page
          flash.keep
          redirect_to movies_path(:sort_column => session[:sort_column], :ratings => session[:ratings])
      end

      @movies = Movie.with_ratings(@ratings_selected).order(params[:sort_column])
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end