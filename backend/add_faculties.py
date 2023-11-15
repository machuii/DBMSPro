import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "django_project.settings")
django.setup()

from inclass.models import Student, Course, Faculty
from django.contrib.auth.models import User
        
with open('faculties.txt', 'r') as file:
    gen_list = file.readlines()
    list_len = len(gen_list)
    for i in range (0, list_len, 3):

        user = User.objects.create_user(username=gen_list[i].strip(), password=gen_list[i].strip())
        course = Course.objects.get(course_id=gen_list[i + 2].strip())
        faculty = Faculty(faculty_id=gen_list[i].strip(), user=user, name=gen_list[i + 1].strip(), course_taken=course)
        faculty.save()
    file.close()
