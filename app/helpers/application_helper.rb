#encoding:utf-8
module ApplicationHelper
  def show_error_message(message = I18n.t('activerecord.errors.messages.blank'))
    ['<small class="error">', message, '</small>'].join.html_safe
  end

  def flash_class(type)
    { notice: 'success',
      alert:  'info',
      error:  'warning' }[type]
    end

    def form_params(parent, child)
      child.new_record? ? [parent, child] : child
    end

    def topic_info(topic)
      info = ["<small class='details'>"]
    # info << badge_for(topic.forum) unless params[:controller] == 'forums' &&
    #                                       params[:action]     == 'show'
    info << info_for(topic.user)   unless params[:controller] == 'users'
    info << time_for(topic)<< '</small>' 
    info << vote_for(topic) 
    info.join.html_safe
  end

  def event_info(event)
    info = ["<small class='details'>"]
  #  info << link_to(event.event_type, '#', class: 'badge')    
  info << info_for(event.user)   unless params[:controller] == 'users'
  info << time_for(event)<< '</small>' 
  info << vote_for(event) 
  info.join.html_safe
end

def groupbuy_info(groupbuy)
  info = ["<small class='details'>"]   
  info << info_for(groupbuy.user)   unless params[:controller] == 'users'
  info << time_for(groupbuy)<< '</small>' 
  info << vote_for(groupbuy) 
  info.join.html_safe
end


def comment_info(comment)
  info = ["<small class='details'>"]
  if comment.topic
    info << badge_for(comment.topic) unless params[:controller] == 'topics'
  elsif comment.event
    info << badge_for(comment.event) unless params[:controller] == 'event'
  end
  info << info_for(comment.user)   unless params[:controller] == 'users'
  info << time_for(comment)
  info << "<div class='owner-buttons-for-c'>" << owner_buttons_for_c(comment) << "</div>" if current_user == comment.user
  info << '</small>'    
  info << vote_for(comment)
  info.join.html_safe
end

def participant_info(participant, price)

  info = ["<small class='details'>"]
  info << '<span class="badge">' << info_for(participant.user) << '</span>' if participant.user
  info << link_to(is_paid(participant), '#', class: 'badge') if participant.total.to_f > 0
  info << '¥' + participant.total.to_s if participant.status_pay.in?([1, 2])
  info << time_for(participant)
  if participant.groupbuy_id
    info << ' | ' + participant.quantity.to_s + Groupbuy.find(participant.groupbuy_id).goods_unit
  else
    info << participant.quantity.to_s + ' ' + t(:people)
  end
  if participant.tracking_number.present? && (participant.user_id == current_user.try(:id) || is_admin?)
    info << "<div class='tracking-number'><span class='tracking-title'>" << t(:tracking_number) << "</span><span class='number'>" << format_string(participant.tracking_number) << "</span></div>"
  end
  info << "<div class='owner-buttons-for-p'>" << owner_buttons_for_p(participant, price) << "</div>" if current_user == participant.user
  info << '</small>'
  
  info.join.html_safe
end

def is_paid participant
  if participant.status_pay == 1
    if participant.status_ship == 1
      paid = t(:shiped)
    else
     paid = t(:paid)
   end
 elsif participant.status_pay == 0
   paid= t(:unpaid)
 elsif participant.status_pay == 2
   paid = t(:waiting_confirm)
 end
 paid
end

def is_shiped participant
  if participant.status_ship == 1
   shiped = t(:shiped)
 elsif participant.status_ship == 0
   shiped= t(:unshiped)
 elsif participant.status_ship == 2
   shiped = t(:received)
 end
 shiped
end

def badge_for(object)
  link_text = object.try(:title) || object.name
  link_to(link_text, object, class: 'badge')
end

def info_for(user)
 link_text = image_tag(user.try(:avatar), class:'user-thumb') + ' ' + user.try(:nickname)
 link_to(link_text, profile_path(user.id)) if user
end

def time_for(object)
  ', ' + time_ago_in_words(object.created_at) + ' '+t(:ago)+' '
end

def vote_for(object)
  ' '
    # '<a href="#"><i class="fa fa-thumbs-o-up"></i>2</a> <a href="#" style="margin-left:50px"><i class="fa fa-thumbs-o-down"></i>3</a>'
  end 

  def owner_buttons_for_c(comment)
    link_to('<span class="icons"><i class="fa fa-pencil"></i>'.html_safe + t(:edit) + '</span>'.html_safe, edit_comment_path(comment)) + ' | ' +
    link_to('<span class="icons"><i class="fa fa-times"></i>'.html_safe + t(:delete) + '</span>'.html_safe, comment, method: :delete)
  end

  def owner_buttons_for_p(participant, price)
    link_to('<span class="icons"><i class="fa fa-pencil"></i>'.html_safe + t(:edit) + '</span>'.html_safe, edit_participant_path(participant)) + ' | ' +
    link_to('<span class="icons"><i class="fa fa-times"></i>'.html_safe + t(:delete) + '</span>'.html_safe, participant_path(participant), method: :delete) + "#{participant.groupbuy_id.present? ? ' | ' : ''}" +
    link_to('<span class="icons groupbuy-detail"><i class="fa fa-bars"></i>'.html_safe + t(:detail) + '</span>'.html_safe, participant_path(participant)) +
    if participant.user_id == current_user.try(:id) && participant.status_pay == 0 && price.to_f > 0
      link_to(' | <span class="icons"><i class="fa fa-jpy"></i>'.html_safe  + t(:pay) + '</span>'.html_safe, wechat_pay_path(participant_id: participant.id))
    else
      ''  
    end
  end

  def markdown(text, options= {links: true})
    render_options = {
      filter_html:     true,
      hard_wrap:       true,
      no_links:        !options[:links],
      highlight: true
    }
    renderer = Redcarpet::Render::HTML.new(render_options)

    extensions = {
      autolink:           true,
      fenced_code_blocks: true,
      lax_spacing:        true,
      no_intra_emphasis:  true,
      strikethrough:      true,
      superscript:        true,
      highlight:          true
    }
    Redcarpet::Markdown.new(renderer, extensions).render(text).html_safe
  end

  def format_string string
    str = string
    count = str.length / 4
    count.times do |t|
      str[4 * (t + 1) - 1] += ' '
    end
    str.strip
  end

  def choose_text en_text, zh_text
    if session[:locale] == 'en'
      en_text
    else
      if zh_text.present?
        zh_text
      else
        en_text
      end
    end
  end


  def current_title groupbuy
    return nil if groupbuy.class.to_s != 'Groupbuy'
    Rails.logger.info "-------------#{session[:locale]}"
    if session[:locale] == 'zh'
      if groupbuy.zh_title.present?
        Rails.logger.info "-------------yes-zh"
        return groupbuy.zh_title
      else
        Rails.logger.info "-------------no-zh"
        return groupbuy.en_title
      end
    elsif session[:locale] == 'en'
      if groupbuy.en_title.present?
        Rails.logger.info "-------------yes-en"
        return groupbuy.en_title
      else
        Rails.logger.info "-------------no-en"
        return groupbuy.zh_title
      end
    end
  end

  def current_body groupbuy
    if session[:locale] == 'zh'
      if groupbuy.zh_body.present?
        return groupbuy.zh_body
      else
        return groupbuy.en_body
      end
    elsif session[:locale] == 'en'
      if groupbuy.en_body.present?
        return groupbuy.en_body
      else
        return groupbuy.zh_body
      end
    end
  end

  def translate_of word, number = nil
    begin
      word = word.to_sym
      if session[:locale] == 'zh'
        if number
          if ZH_TO_EN[word].present?
            return "#{number.to_s}<span class='two-spaces'>#{word}</span>"
          else
            return EN_TO_ZH[word].present? ? "#{number.to_s}<span class='two-spaces'>#{EN_TO_ZH[word]}</span>" : number.to_s + word.to_s
          end
        else
          return EN_TO_ZH[word].present? ? EN_TO_ZH[word] : word
        end
      elsif session[:locale] == 'en'
        if number
          if EN_TO_ZH[word].present?
            return number.to_s + word.to_s
          else
            return ZH_TO_EN[word].present? ? (number.to_s + ZH_TO_EN[word]) : "#{number.to_s}<span class='two-spaces'>#{word}</span>"
          end
        else
          return ZH_TO_EN[word].present? ? ZH_TO_EN[word] : word
        end
      end
    rescue
      return number.to_i.to_s + word.to_s
    end
  end
end
