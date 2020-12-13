class Subject < ApplicationRecord
  belongs_to :term
  has_many :courses
  
  def self.ImportSubjectsForTerm!(term)
    json = CourseScraper.get_subjects(term.term_code)
    all_subjects = []
    json.each do |subject_json|
      s = Subject.new
      s.subject_code = subject_json['code']
      s.subject_description = subject_json['description']
      s.term_id = term.id
      all_subjects.append(s)
    end
    all_subjects.each(&:save)
  end
end
