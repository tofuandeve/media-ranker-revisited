class WorksController < ApplicationController
  # We should always be able to tell what category
  # of work we're dealing with
  before_action :category_from_work, except: [:root, :index, :new, :create]
  before_action :check_authorized_user, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_action :check_work_owner, only: [:edit, :update, :destroy]
  
  def root
    @albums = Work.best_albums
    @books = Work.best_books
    @movies = Work.best_movies
    @best_work = Work.order(vote_count: :desc).first
  end
  
  def index
    @works_by_category = Work.to_category_hash
  end
  
  def new
    @work = Work.new
  end
  
  def create
    @work = Work.new(media_params)
    @work.user = @login_user
    @media_category = @work.category
    if @work.save
      flash[:status] = :success
      flash[:result_text] = "Successfully created #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not create #{@media_category.singularize}"
      flash[:messages] = @work.errors.messages
      render :new, status: :bad_request
    end
  end
  
  def show
    @votes = @work.votes.order(created_at: :desc)
  end
  
  def edit
  end
  
  def update
    @work.update_attributes(media_params)
    if @work.save
      flash[:status] = :success
      flash[:result_text] = "Successfully updated #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not update #{@media_category.singularize}"
      flash.now[:messages] = @work.errors.messages
      render :edit, status: :not_found
    end
  end
  
  def destroy 
    @work.destroy
    flash[:status] = :success
    flash[:result_text] = "Successfully destroyed #{@media_category.singularize} #{@work.id}"
    redirect_to root_path
  end
  
  def upvote
    flash[:status] = :failure
    if @login_user
      vote = Vote.new(user: @login_user, work: @work)
      if vote.save
        flash[:status] = :success
        flash[:result_text] = "Successfully upvoted!"
      else
        flash[:result_text] = "Could not upvote"
        flash[:messages] = vote.errors.messages
      end
    else
      flash[:result_text] = "You must log in to do that"
    end
    
    redirect_back fallback_location: work_path(@work)
  end
  
  private
  
  def media_params
    params.require(:work).permit(:title, :category, :creator, :description, :publication_year)
  end
  
  def category_from_work
    @work = Work.find_by(id: params[:id])
    render_404 unless @work
    @media_category = @work.category.downcase.pluralize
  end
  
  def check_authorized_user
    if !@login_user
      flash[:status] = :failure
      flash[:result_text] = "You must log in to do that"
      redirect_to root_path
      return
    end
  end
  
  def check_work_owner
    if @login_user != @work.user
      flash[:status] = :failure
      flash[:result_text] = "Only owner can update #{@work.title}"
      redirect_to root_path
      return
    end
  end
end