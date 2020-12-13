# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_schedule(student,schedule_name, classes)
        @schedule = Schedule.new
        @schedule.update_attributes(:name => schedule_name)
        student.schedules.push(@schedule)
        classes.each do |class_hash|
                print(class_hash)
                @course = Course.where(:abbreviated_subject => class_hash[:abbreviated_subject], :course_number => class_hash[:course_number], :section_number => class_hash[:section_number], :term_id => class_hash[:term_id])
                #print(@course.first.full_subject)
                @schedule.courses.push(@course.first)
        end
        
        @schedule.save
        @user.schedules.push(@schedule)   
        @user.save
end


#@terms = Term.ImportTermList!
#@term = Term.find_by active: 1

@user = User.new
        @user.firstname = 'Lauren'
        @user.lastname = 'Haylock'
        @user.uin = 725000950
        @user.email = 'laurenrhaylock@tamu.edu'
        @user.role = 'admin'
        @user.password = "Temp"
        @user.save
       

#print(@terms)
#@terms.each do |t|
#        Term.create!(t)
#end 
#@term = @terms.all[0]
#@term.update_attributes(:active => 1)

