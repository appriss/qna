class SearchesController < ApplicationController
  before_filter :login_required, :except => %w[index]

  subtabs :index => [[:newest, %w(created_at desc)], [:hot, [%w(hotness desc), %w(views_count desc)]], [:votes, %w(votes_average desc)], [:activity, %w(activity_at desc)], [:expert, %w(created_at desc)]],
          :unanswered => [[:newest, %w(created_at desc)], [:votes, %w(votes_average desc)], [:mytags, %w(created_at desc)]],
          :show => [[:votes, %w(votes_average desc)], [:oldest, %w(created_at asc)], [:newest, %w(created_at desc)]]

  def index
    options = {}
    unless params[:q].blank?
      @search_text = params[:q]
      page = (params[:page] || 1).to_i
      per_page = 25
      start = (page-1) * per_page

      options[:group_id] = current_group.id

      @search = Search.new(:query => @search_text)

      if !@search_text.blank?
        @solr_results = Solr.search_edismax(@search_text, :start => start, :row => per_page)
        if @solr_results.key? "error"
          flash[:error] = "There was a problem with your search: #{@solr_results["error"]["msg"]}"
          @results = []
          @total_count = 0
        else
          @results = []
          @solr_results["response"]["docs"].map {|d| d["id"]}.each do |question_id|
            @results << Question.find(question_id)
          end
          @total_count = @solr_results["response"]["numFound"]
          total_count = @total_count
          (class << @results; self; end).send :define_method, :current_page do
            page
          end
          (class << @results; self; end).send :define_method, :num_pages do
            ((total_count.to_i * 1.0) / per_page).ceil
          end
          (class << @results; self; end).send :define_method, :limit_value do
            per_page
          end
          @highlight_info = @solr_results["highlighting"]
          # @questions = Question.filter(@search_text, options)
          @highlight = @search_text.split
          # @questions = Question.where(options).page(params["page"])
          # @highlight = ""
        end
      else
        @results = Question.where(options).page(params["page"])
      end
    else
      @results = []
    end

    respond_to do |format|
      format.html
      format.js do
        render :json => {:html => render_to_string(:partial => "questions/question",
                                                   :collection  => @questions)}.to_json
      end
      format.json { render :json => @questions.to_json(:except => %w[_keywords slugs watchers]) }
    end
  end

  def show
    @search = current_user.searches.by_slug(params[:id], :group_id => current_group.id)
    if @search.nil?
      redirect_to search_index
    end

    find_questions(@search.conditions)
  end

  def create
    @search = Search.new
    @search.safe_update(%w[name query], params[:search])
    @search.user = current_user
    @search.group = current_group

    respond_to do |format|
      if @search.save
        format.html { redirect_to search_path(@search) }
      else
        format.html do
          params[:q] = @search.query
          render 'index'
        end
      end
    end
  end

  def destroy
    @search = current_user.searches.by_slug(params[:id], :group_id => current_group.id)
    @search.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end
end
