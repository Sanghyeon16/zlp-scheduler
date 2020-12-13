class StudentController < ApplicationController
  
   before_action :require_student, only: [:view_terms, :add_schedule, :update_courses, :update_sections, :create_schedule, :view_schedule,:delete_schedule]  

  def in_open_term?
    cohort = Cohort.find(@user.cohort_id)
    if !@term.opendate
      return false
    end
    return DateTime.current >= @term.opendate && DateTime.current < @term.closedate && cohort.term_id == @term.id
  end
  
  def view_terms
    id = session[:user_id]
    @user = User.find(id)
    @term = Term.find_by active: 1;
    cohort = Cohort.find(@user.cohort_id)
    date_dict = { "M" => "Monday", "T" => "Tuesday", "W" => "Wednesday", "TR" => "Thursday", "F" => "Friday"}
    if cohort.chosen_time.present?
      chosen_timeslot = TimeSlot.find(cohort.chosen_time)
      chosen_time_start = chosen_timeslot.time
      chosen_time_end = chosen_time_start.advance(:hours => 2)
      @chosen_time = chosen_time_start.strftime("%H:%M") + " - " + chosen_time_end.strftime("%H:%M") + " " + date_dict[chosen_timeslot.day]
    end
    
    if not in_open_term?
      redirect_to closed_path and return
    end
    if @user.schedules
      @schedules = @user.schedules
    else 
      @schedules = []
    end
  end
  
  def add_schedule
    id = session[:user_id]
    @user = User.find(id)
    
    if @user.schedules.length == 3
      flash[:warning] = "You may only add 3 schedules."
      redirect_to view_terms_path
    end
    
    @schedule = Schedule.new
    
    @term = Term.find_by active: 1;
    @subjects = @term.subjects
    @subjects = @subjects.uniq
    @course_options = [];
    @section_options = [];
    
  end
  
  def update_courses
    @select_id = params[:id]
    if params[:dept_id].empty?
      @course_options = [].insert(0, "")
    else 
      subj = Subject.find(params[:dept_id])
      # map to name and id for use in our options_for_select
      @term = Term.find_by active: 1;
      @courses = Course.where(:abbreviated_subject => subj.subject_code, :term_id => @term.id).order(course_number: :asc)
      @course_options = [];
      @courses.each do |c|
        @course_options.push(c.course_number)
      end
      @course_options = @course_options.uniq
      @course_options.insert(0, "")
    end
  end
  
  def update_sections
    # updates artists and songs based on genre selected
    subj = Subject.find(params[:dept_id])
    @select_id = params[:id]
    if params[:course_num_id].empty?
      @section_options = [].insert(0, "")
    else
      course_num = params[:course_num_id]
      # map to name and id for use in our options_for_select
      @term = Term.find_by active: 1;
      @sections = Course.where(:abbreviated_subject => subj.subject_code, :course_number => course_num, :term_id => @term.id).order(section_number: :asc)
      @section_options = [];
      @sections.each do |c|
        @section_options.push(c.section_number)
      end
      @section_options = @section_options.uniq
      @section_options.insert(0, "")
    end
  end
  
  def create_schedule
    id = session[:user_id]
    @user = User.find(id)
    if params[:schedule][:name] == ""
      flash[:warning] = 'Schedule must include a name.'
      redirect_to add_schedule_path
    else
      #add courses to schedule, schedule to user
      @term = Term.find_by active: 1;
      @schedule = Schedule.new
      @schedule.update_attributes(:name => params[:schedule][:name])
      @user.schedules.push(@schedule)
      warning_word = ""
      7.times do |n|
        subj_symb = "dept_id_#{n+1}".to_sym
        number_symb = "course_num_id_#{n+1}".to_sym
        section_symb = "section_num_id_#{n+1}".to_sym
        check_symb = "mand_#{n+1}".to_sym
        
        if (params[subj_symb] != "" and params[number_symb] == "") or (params[subj_symb] != "" and params[section_symb] == "")
          warning_word = " Courses without course number or section number will not be added in the schedule!"
        end
        
        if params[subj_symb] != "" and params[number_symb]!= "" and params[section_symb]!=""
          subj = Subject.find(params[subj_symb]).subject_code
          @course = Course.where(:abbreviated_subject => subj, :course_number => params[number_symb], :section_number => params[section_symb], :term_id => @term.id)
          @schedule.courses.push(@course)
          if !params[check_symb].nil?
            #update mandatory attribute
            @sched_table = ScheduleToCourse.find_by course_id: @course.ids
            @sched_table.update_attributes(:mandatory => true)
          end
        end
      end
      flash[:notice] = 'Schedule added!' + warning_word
      redirect_to view_terms_path
    end
  end
  
  def view_schedule
    @schedule = Schedule.find(params[:id])
    @courses = @schedule.courses
    @associations = ScheduleToCourse.where(:schedule_id => @schedule.id)
  end
  
  def schedule_params
    params.require(:schedule).permit(:name, course_ids: [])
  end
  
  def delete_schedule 
    @schedule = Schedule.find(params[:id])
    @schedule.destroy
    
    flash[:notice] = 'Schedule deleted!'
    redirect_to view_terms_path
  end
  
  def closed
    id = session[:user_id]
    @user = User.find(id)
  end
end
