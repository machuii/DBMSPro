import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "django_project.settings")
django.setup()

from inclass.models import Student, Course
from django.contrib.auth.models import User
        
with open('courses.txt', 'r') as file:
    gen_list = file.readlines()
    list_len = len(gen_list)
    for i in range (0, list_len, 3):
        if (gen_list[i + 2].strip() == "F"):
            elective = False
        else:
            elective = True
        course = Course(course_id=gen_list[i].strip(), course_name=gen_list[i + 1].strip(), elective=elective)
        course.save()
    file.close()
