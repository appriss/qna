class Solr
  def Solr.add_document(question)
    {"add" => 
      {"doc" => {
          "id" => question.id,
          "title" => strip_tags(question.title),
          "questionBody" => strip_tags(question.body.present? ? question.body : question.title),
          "tag" => question.tags,
          "answer" => question.answers.map {|a| strip_tags(a.body)},
          "comment" => [question.comments.map {|c| strip_tags(c.body)} + question.answers.map{|a| a.comments.map {|c| strip_tags(c.body)} }].flatten,
          "author" => [question.user.login, question.answers.map{|a| a.user.login}].flatten.sort.uniq,
          "questionAuthor" => question.user.login,
          "answerAuthor" => question.answers.map{|a| a.user.login}.flatten.sort.uniq,
          "vote_score" => question.votes_average,
          "views" => question.views_count,
          "num_answers" => question.answers.count,
          "last_modified" => format_time(Time.now),
          "created" => format_time(question.created_at),
          "answered" => question.accepted,
          "banned" => question.banned,
          "num_followers" => question.followers_count,
          "followed_by" => question.followers.map(&:display_name),
        }
      }
    }.to_json[1..-2]
  end

  def Solr.remove_document(question_id)
    {"delete" => {"id" => question_id}}.to_json[1..-2]
  end

  def Solr.update (instructions, commit=false)
    instructions = [instructions].flatten
    uri = URI.parse("http://127.0.0.1:8983")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new("/solr/qna/update" + (commit ? "?commit=true" : ""))
    request.add_field('Content-Type', 'text/json')
    json = "{" + instructions.join(",") + "}"
    request.body = json
    response = http.request(request)
  end

  def self.strip_tags (str)
    ActionView::Base.full_sanitizer.sanitize(str)
  end

  def self.format_time (time)
    time.utc.to_s.gsub(/ UTC/, 'Z').gsub(/ /, "T")
  end

end
