
import os
import django
import random

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "django_project.settings")
django.setup()

from inclass.models import Student, Session, Classes_Attended
from django.contrib.auth.models import User

sid = input()
number = int(input())
session = Session.objects.get(sid=sid.strip())
if session.faculty.course_taken.elective is True:
    students = list(session.faculty.course_taken.students_elected.all())
else:
    students = list(Student.objects.all().filter(batch=session.batch))
students = random.sample(students, number)
print(students)
for student in students:
    student.attended_sessions.add(session)
    student_course = Classes_Attended.objects.get_or_create(course=session.faculty.course_taken, student=student)[0]
    student_course.classes_attended += 1
    student_course.save()
    student.save()

        