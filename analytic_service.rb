module AnalyticService

  def active_class? by, entity
    return 'active' if (request.GET.blank? && entity=='questions' && by=='date')
    (request.GET[:by]==by && request.GET[:entity]== entity) ? 'active' : nil
  end

  def column_chart_data
    if params[:entity] == "votes"
      @data.map{|data| [data[:_id].values.join('-').to_date.strftime('%b. %-d, %y'),data[:male_votes],data[:female_votes],data[:total_votes]]}
    else
      @data.map{|data| [data[:_id].values.join('-').to_date.strftime('%b. %-d, %y'),data[:male],data[:female],data[:total]]}
    end
  end

  def question_text question, celebrity
    celeb_ids = question.asked_to - [current_user.id.to_s]
    celeb_links = celeb_ids.map do |id|
    "<a class=\"ajax-modal-opener-profile\" data-href=\"/#{(celebrity[id][:username] rescue '')}?modal=true\" data-modal-title=\"/#{t('analytics.profile_summary')}\" href=\"#-\">#{(celebrity[id][:name].capitalize rescue '')}</a>"
    end
    multiple_celeb = question.asked_to.many? ? '<i class="fa fa-users"></i>' : ''
    answered = '<span>'+(question.answerers.include?(current_user.id.to_s) ? '&#x2713;' : ' ')+'</span>'
    participant = celeb_ids.count == 2 ? t('analytics.participants') : celeb_ids.count == 1 ? t('analytics.participant') : ''
    quest_text = "<div> #{multiple_celeb} #{answered} <a class=\"link-color\" href=\"/analytics/questions/#{question.id.to_s}\">#{question.text}</a><br> #{participant} #{celeb_links[0]} #{celeb_links.flatten.count>1 ? 'and' : ''} #{celeb_links[1]} </div>"
  end

  def select_options type
    case type
    when 'date'
      dates = %w(7 14 30 60 90).map{|i| [t('analytics.last')+i.to_s+t('analytics.days'),i]}.unshift([t('analytics.today'),0])
      dates << [t('analytics.beginning'),'infinite']
    when 'asker_gender'
      [[t('analytics.any'),nil],[t('analytics.male'),'male'],[t('analytics.male'),'female']]
    when 'asker_state'
      [[t('analytics.any'),nil]].concat(CS.states(:us).map{|sc,sn| [sn,sc.to_s]})
    when 'is_debate'
      [[t('analytics.any'),nil],[t('analytics.yes'),1],[t('analytics.no'),0]]
    when 'is_answered'
      [[t('analytics.any'),nil],[t('analytics.yes'),1],[t('analytics.no'),0]]
    when 'sort_by'
     [[t('analytics.date_desc'),'date_desc'],[t('analytics.date_asc'),'date_asc'],[t('analytics.vote_desc'),'vote_desc'],[t('analytics.vote_asc'),'vote_asc'],[t('analytics.lvote_desc'),'last_vote_desc'],[t('analytics.lvote_asc'),'last_vote_asc'],[t('analytics.sentiment_ptn'),'sentmnt_desc'],[t('analytics.sentiment_ntp'),'sentmnt_asc']]
    end
  end

  def sentiment_type sentiment
    case sentiment
    when 0
      t('analytics.hnegative')
    when 1
      t('analytics.negative')
    when 2
      t('analytics.hneutral')
    when 3
      t('analytics.positive')
    when 4
      t('analytics.hpositive')
    end
  end

  def table_chart_data
    if ( params[:by] == 'date' || params[:by].blank? )
      if params[:entity] == "votes"
        @data.map{|data| [data[:_id].values.join('-').to_date.strftime('%b. %-d, %y'),data[:male_votes].to_s,data[:female_votes].to_s,data[:other_votes].to_s,data[:total_votes].to_s]}
      else
        @data.map{|data| [data[:_id].values.join('-').to_date.strftime('%b. %-d, %y'),data[:male].to_s,data[:female].to_s,data[:other].to_s,data[:total].to_s]}
      end
    else
      if params[:entity] == "votes"
        @data.map{|data| [data[:_id][:state_name].to_s,data[:male_votes].to_s,data[:female_votes].to_s,data[:other_votes].to_s,data[:total_votes].to_s]}
      else
        @data.map{|data| [data[:_id][:state_name].to_s,data[:male].to_s,data[:female].to_s,data[:other].to_s,data[:total].to_s]}
      end
    end
  end
end