import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "django_project.settings")
django.setup()

from inclass.models import Student, Course
from django.contrib.auth.models import User
        
with open('NTC.txt', 'r') as file:
    gen_list = file.readlines()
    list_len = len(gen_list)
    for i in range (0, list_len):
        student = Student.objects.get(roll_no=gen_list[i].strip())
        ntc_course = Course.objects.get(course_id="CS4021D")
        student.elected_courses.add(ntc_course)
        student.save()
    file.close()


        
with open('DAA.txt', 'r') as file:
    gen_list = file.readlines()
    list_len = len(gen_list)
    for i in range (0, list_len):
        student = Student.objects.get(roll_no=gen_list[i].strip())
        ntc_course = Course.objects.get(course_id="CS4050D")
        student.elected_courses.add(ntc_course)
        student.save()
    file.close()


        
with open('FOP.txt', 'r') as file:
    gen_list = file.readlines()
    list_len = len(gen_list)
    for i in range (0, list_len):
        student = Student.objects.get(roll_no=gen_list[i].strip())
        ntc_course = Course.objects.get(course_id="CS4067D")
        student.elected_courses.add(ntc_course)
        student.save()
    file.close()