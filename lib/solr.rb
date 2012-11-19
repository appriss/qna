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

  def Solr.search (query, opts=nil)
    opts ||= {}
    opts = {
      :highlight => true,
      :start => 0,
    }.merge(opts)
    params = {
      "q" => URI::encode(query),
      "fl" => "id",
      "wt" => "ruby",
      "indent" => "true",
      "hl" => "true",
      "hl.fl" => "text",
      "hl.simple.pre" => URI::encode("<span class=\"highlight\">"),
      "hl.snippets" => 3,
      "hl.fragsize" => 100,
      "hl.mergeContiguous" => "true",
      "hl.alternateField" => "text",
      "hl.useFastVectorHighlighter" => "true",
      "hl.maxAlternateFieldLength" => 500,
      "hl.simple.post" => URI::encode("</span>"),
      "start" => opts[:start],
    }
    args = params.map {|key, _| "#{key}=#{params[key]}"}.join("&")
    uri = URI.parse("http://127.0.0.1:8983/solr/qna/select?#{args}")
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    eval(response.body)
  end

  def Solr.search_edismax (query, opts=nil)
    opts ||= {}
    opts = {
      :highlight => true,
      :start => 0,
      :row => 25,
    }.merge(opts)
    params = {
      "q" => URI::encode(query),
      "typeDef" => "edismax",  # eDisMax is more user friendly/fuzzy than default.  Default is better for stricter searches
      "f.votes.qf" => "vote_score",  # Setup an alias "votes" for "vote_score" field
      "bf" => URI::encode("sum(vote_score, num_followers, num_visits)"),
      "qf" => URI::encode("title^1.6 questionBody answer comment^0.9"),
      "fl" => "id",
      "wt" => "ruby",
      "rows" => opts[:row],
      "indent" => "true",
      "hl" => "true",
      "hl.fl" => "text",
      "hl.simple.pre" => URI::encode("<span class=\"highlight\">"),
      "hl.snippets" => 3,
      "hl.fragsize" => 100,
      "hl.mergeContiguous" => "true",
      "hl.alternateField" => "text",
      "hl.useFastVectorHighlighter" => "true",
      "hl.maxAlternateFieldLength" => 500,
      "hl.simple.post" => URI::encode("</span>"),
      "start" => opts[:start],
    }
    args = params.map {|key, _| "#{key}=#{params[key]}"}.join("&")
    uri = URI.parse("http://127.0.0.1:8983/solr/qna/select?#{args}")
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    eval(response.body)
  end

  def self.strip_tags (str)
    ActionView::Base.full_sanitizer.sanitize(str)
  end

  def self.format_time (time)
    time.utc.to_s.gsub(/ UTC/, 'Z').gsub(/ /, "T")
  end

end
