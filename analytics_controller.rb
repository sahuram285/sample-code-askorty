class AnalyticsController < ApplicationController
  layout "analytics"
  before_filter :set_days, :must_be_celebrity
  include AnalyticService

  def getdata
  end

  def index
    f = ({ 
      by: params[:by],
      entity: params[:entity],
      loggedin_user_id: current_user.id.to_s, # This is only accessible thru login so, no need to rescue
      offset: params[:offset],
      to_date: params[:to_date]
    })
    @analytic = Analytics.new(f)
    @data = @analytic.getData
    @data_count = @analytic.getDataCount
  end

  def qlist
    f = ({
      questions_only: true,
      answered: params[:answered],
      debate: params[:debate],
      gender: params[:gender],
      offset: params[:offset],
      page: params[:page].to_i || 1,
      state: params[:state],
      sort_by: params[:sort_by],
      sentiment_from: params[:sentiment_from],
      sentiment_to: params[:sentiment_to],
      vcount_from: params[:vcount_from],
      vcount_to: params[:vcount_to],
      loggedin_user_id: current_user.id.to_s, # This is only accessible thru login so, no need to rescue
    })
    @questions = Analytics.new(f).getQuestions
    @table_chart = get_question_table_data @questions
  end

  def show
    f = ({ 
      by: params[:by] || 'date',
      entity: params[:entity] || 'votes',
      loggedin_user_id: current_user.id.to_s, # This is only accessible thru login so, no need to rescue
      offset: params[:offset],
      to_date: params[:to_date],
      from_date: params[:from_date],
      q_id: params[:qid]
    })
    # only visible to those users, who are asker
    if @question = Question.find(params[:qid])
      redirect_to '/401' and return unless @question.asked_to.include? current_user.id.to_s
    else
      redirect_to '/404' and return
    end
    @analytic = Analytics.new(f)
    @q_info = @analytic.question_info.first
    @data = @analytic.getQuestionData
  end

  private

    def get_question_table_data questions
      celebrity = Analytics.celebrity_info questions
      questions.map do |quest|
        { "text": question_text(quest, celebrity),
          "sentiment": "#{quest.sentiment} - #{sentiment_type(quest.sentiment)}",
          "votes": quest.requestor_count.to_s,
          "state": quest.state_name.to_s,
          "gender": quest.asker_gender.to_s.try(:capitalize),
          "last_vote": (quest.last_vote_at.strftime('%b. %-d, %y') rescue t(:not_available)),
          "created_at": quest.created_at.strftime('%b. %-d, %y')
        }.values
      end
    end

    def must_be_celebrity
      if current_user.present?
        redirect_to '/401' and return unless current_user.has_role?("celebrity")
      else
        redirect_to '/users/login' and return
      end
    end

    def set_days
      @days = (1..30).collect{|d| [pluralize(d, t(:day)), d]}
    end
end