from django.contrib import admin
from .models import Student, Faculty, Course, Session, Classes_Attended, Total_Classes

admin.site.register(Student)
admin.site.register(Faculty)
admin.site.register(Course)
admin.site.register(Session)
admin.site.register(Classes_Attended)
admin.site.register(Total_Classes)
# Register your models here.
