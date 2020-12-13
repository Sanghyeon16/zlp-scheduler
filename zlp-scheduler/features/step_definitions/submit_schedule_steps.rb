Given /The "(.*)" terms exist/ do |term|
    
    #@term = Term.create(term)
    @term = Term.create(:name=>term)
    @term.opendate = Date.current.yesterday
    @term.closedate = Date.current.tomorrow
    @term.active = true
end

Given(/^Registered student and Create term and courses$/) do
 
  Capybara.server = :webrick
  
  @testing_department = ["ABC","DEF","GHI","JKL","MNO","PQR","STU"]
 
  @cohort = FactoryBot.create(:cohort, :name=>"Apple", :term_id=>@term.id)
  @cohort.save()

  @user = FactoryBot.create(:user, :role=>"student", :cohort_id=>@cohort.id)
  @user.save()
  
  @testing_department.each do |test_subject|
    @subject = FactoryBot.create(:subject, :subject_code=>test_subject, :subject_description=>"Test", :term_id=>@term.id)
    i = 0
    while i < 4 do
      @course = FactoryBot.create(:course, :abbreviated_subject=>test_subject, :term_id=>@term.id, :subject_id=>@subject.id)
      @course.save()
      i = i + 1
    end
    @subject.save()
  end
 
  @fake_schedule_name = []
  
end

Then /I should see (.*) schedule in the table/ do |row_num|
  #Default with 2 row table
  expect(page).to have_xpath(".//tr", count: row_num.to_i + 2)
  #print(page.all("#studentTermTable tr").count)
  
end

Then ('I click add schedule button') do
  click_link("Add Schedule")
end

Then ('I click save schedule button') do
  click_button("Save Schedule")
end

Then ('I click cancel button') do
  click_link("Cancel")
end

Then ('I click the added schedule') do
  click_link(@test_schedule_name)
end

def select_option_in_dropdown(target, rec)
  
  dropdown_list = page.driver.browser.find_element(:id, target)
  options = dropdown_list.find_elements(tag_name: 'option')
  #options.each { |option| print(option.text)}
  department_selected = options[rand(1...options.length)].text # Start from idx 1, avoid blank
  select(department_selected, from: target)
  rec.append(department_selected)
end  

def select_course_info(i, if_course_num, if_course_sec, mandatory)
  
  rec = []
  select_option_in_dropdown('dept_select_'+i, rec)
  
  if if_course_num
    select_option_in_dropdown('course_num_select_'+i, rec)
  end
  
  if if_course_num and if_course_sec
    select_option_in_dropdown('section_num_select_'+i, rec)
  end
  
  if mandatory
    check "mand_"+ i
  end

  return rec
  
end


Then ("I fill in my courses") do
  
  @test_schedule_name = Faker::Name.last_name
  fill_in "Schedule Name:", :with => @test_schedule_name
  
  @record = []
  i = 1
  while i <= 3 do
    madatory = [true, false].sample
    @record.append(select_course_info(i.to_s, true, true, madatory))
    i += 1
  end
  #print(@record)
end

Then ("I fill in courses without select course number or section number randomly") do
  
  n = Faker::Name.last_name
  while @fake_schedule_name.include? n do
    n = Faker::Name.last_name
  end
  
  @test_schedule_name = n
  fill_in "Schedule Name:", :with => @test_schedule_name
  
  @record = []
  i = 1
  while i <= 4 do
    mandatory = [true, false].sample
    num_sel = [true, false].sample
    sec_sel = [true, false].sample
    r = select_course_info(i.to_s, num_sel, sec_sel, mandatory)
    if r.length == 3
      @record.append(r)
    end
    i += 1
    #print(num_sel,sec_sel)
  end
  #print(@record)
end

Then ("I fill in my courses without filling schedule name") do
  
  @record = []
  i = 1
  while i <= 3 do
    mandatory = [true, false].sample
    @record.append(select_course_info(i.to_s, true, true, mandatory))
    i += 1
  end
  #print(@record)
end

Given('I should see added schedule') do
  #print(@test_schedule_name)
  if page.respond_to? :should
      page.should have_content(@test_schedule_name)
  else
      assert page.has_content?(@test_schedule_name)
  end
  
end

Then ("I should see added course information") do
  #print(@record.length+1)
  if @record != []
    @record.each do |rec|
      rec.each do |info|
        #print(info)
        if page.respond_to? :should
          page.should have_content(info)
        else
          assert page.has_content?(info)
        end
      end
    end
  end
  
  expect(page).to have_xpath(".//tr", count: @record.length + 1)
  #print(page.all("#studentScheduleTable tr").count)
end

Then ("I should see Yes and No") do
  
  expect(page).to have_xpath(".//tr", count: 3)
  expect(page.body.match?("Yes")).to eq true
  expect(page.body.match?("No")).to eq true
  
end
