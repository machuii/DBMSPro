from django.db import models
from django.contrib.auth.models import User
from datetime import timedelta, date
from django.utils import timezone
import uuid

# Create your models here.


class Student(models.Model):
    roll_no = models.CharField(max_length=9, primary_key=True) 
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='student')
    name = models.CharField(max_length=30)
    batch = models.CharField(max_length=4)
    elected_courses = models.ManyToManyField('Course', blank=True)
    attended_sessions = models.ManyToManyField('Session', blank=True)

    def __str__(self) -> str:
        return self.name


class Faculty(models.Model):
    faculty_id = models.CharField(max_length=10, primary_key=True)  
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='faculty')
    name = models.CharField(max_length=30)
    course_taken = models.ForeignKey('Course', on_delete=models.SET_NULL, null=True)

    class Meta:
        verbose_name = "Faculty"
        verbose_name_plural = "Faculties"
    

    def __str__(self) -> str:
        return self.name


class Course(models.Model):
    course_id = models.CharField(primary_key=True, max_length=10)
    course_name = models.CharField(max_length=30)

    def __str__(self) -> str:
        return self.course_name


class Session(models.Model):
    sid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    start_time = models.DateTimeField(auto_now=False, auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    faculty = models.ForeignKey(Faculty, on_delete=models.CASCADE)
    batch = models.CharField(max_length=4)
    duration = models.PositiveIntegerField()  

    def save(self, *args, **kwargs):
        self.end_time = timezone.now() + timedelta(minutes=self.duration)
        super(Session, self).save(*args, **kwargs)


class Classes_Attended(models.Model):
    roll_no = models.ForeignKey('Student', on_delete=models.CASCADE)
    course =  models.ForeignKey('Course', on_delete=models.CASCADE)
    classes_attended  = models.PositiveIntegerField(default=0)

    class Meta:
        verbose_name = "Classes Attended"
        verbose_name_plural = "Classes Attended"

class Total_Classes(models.Model):
    course = models.ForeignKey('Course', on_delete=models.CASCADE)
    batch = models.CharField(max_length=4)
    total_classes = models.PositiveIntegerField(default=0)
    
    class Meta:
        verbose_name = "Total Classes"
        verbose_name_plural = "Total Classes"