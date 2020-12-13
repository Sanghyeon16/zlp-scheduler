class Term < ApplicationRecord
  has_many :courses
  has_many :subjects
  has_many :cohorts

  def self.ImportTermList!
    json_terms = CourseScraper.get_terms
    json_terms.each do |json_term|
      term = Term.new
      term.name = json_term['description']
      term.term_code = json_term['code']
      begin
        term.save
      rescue ActiveRecord::RecordNotUnique
        Rails.logger.debug "Duplicate Term Detected, Ignoring."
      end
    end
    active_term = Term.find_by active: 1;
    if active_term.nil?
      Term.all[0].update_attributes(:active => true)
      Term.update_all opendate: DateTime.yesterday
      Term.update_all closedate: DateTime.yesterday
    end
  end
  
  def import_specific_courses(subjects_str)
    
    subjects = Subject.where(:subject_code => subjects_str)
    
    subjects.each do |subject|
      print(subject.subject_code)
      Course.ImportCourses!(self,subject)
    end
    self.courses_import_complete = true
    self.save
  end
  
  # TODO: This will take awhile, it's probably best to fire it off async
  # => and periodically check `Term.courses_import_complete` to determine
  # => if it is done or not. As it stands, this call will take upwards of 10 min.
  def import_all_courses!
    self.subjects.each do |subject|
      print(subject)
      Course.ImportCourses!(self, subject)
    end
    self.courses_import_complete = true
    self.save
  end
  
end


  
