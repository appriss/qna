
task :init => [:environment] do
  class Question
    def set_created_at; end
    def set_updated_at; end
  end

  class Answer
    def set_created_at; end
    def set_updated_at; end
  end

  class Group
    def set_created_at; end
    def set_updated_at; end
  end

  class Activity
    def set_created_at; end
    def set_updated_at; end
  end

  GC.start
end

task :fixall => [:init, "qna40to41:levels", "qna40to41:activities"] do
end
