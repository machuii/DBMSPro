
import os
import django
import random

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "django_project.settings")
django.setup()

from inclass.models import Student, Session
from django.contrib.auth.models import User

sid = input()
number = int(input())
session = Session.objects.get(sid=sid)
if session.faculty.course_taken.elective is True:
    students = list(session.faculty.course_taken.students_elected)
else:
    students = list(Student.objects.all().filter(batch=session.batch))
students = random.sample(students, number)
print(students)
for student in students:
    student.attended_sessions.add(session)
    student.save()

        