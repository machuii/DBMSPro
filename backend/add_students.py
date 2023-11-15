import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "django_project.settings")
django.setup()

from inclass.models import Student
from django.contrib.auth.models import User
        
with open('CS01.txt', 'r') as file:
    gen_list = file.readlines()
    list_len = len(gen_list)
    for i in range (0, list_len, 2):
        user = User.objects.create_user(username=gen_list[i].strip(), password=gen_list[i].strip())
        student = Student(roll_no=gen_list[i], user=user, name=gen_list[i + 1], batch="CS01")
        student.save()
    file.close()


        
with open('CS02.txt', 'r') as file:
    gen_list = file.readlines()
    list_len = len(gen_list)
    for i in range (0, list_len, 2):
        user = User.objects.create_user(username=gen_list[i].strip(), password=gen_list[i].strip())
        student = Student(roll_no=gen_list[i], user=user, name=gen_list[i + 1], batch="CS02")
        student.save()
    file.close()

        
with open('CS03.txt', 'r') as file:
    gen_list = file.readlines()
    list_len = len(gen_list)
    for i in range (0, list_len, 2):
        user = User.objects.create_user(username=gen_list[i].strip(), password=gen_list[i].strip())
        student = Student(roll_no=gen_list[i], user=user, name=gen_list[i + 1], batch="CS03")
        student.save()
    file.close()

        
with open('CS04.txt', 'r') as file:
    gen_list = file.readlines()
    list_len = len(gen_list)
    for i in range (0, list_len, 2):
        user = User.objects.create_user(username=gen_list[i].strip(), password=gen_list[i].strip())
        student = Student(roll_no=gen_list[i], user=user, name=gen_list[i + 1], batch="CS04")
        student.save()
    file.close()