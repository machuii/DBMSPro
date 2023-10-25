from django.db import models

# Create your models here.

class Courses(models.Model):
    course_id = models.CharField(max_length=7)
    course_name = models.CharField(max_length=30)
    credits = models.IntegerField()


class Sessions(models.Model):
    sid = models.AutoField()
    time = models.TimeField()
    date = models.DateField()
    duration = models.IntegerField()
    course = models.ForeignKey(Courses,on_delete=models.CASCADE)
    batch = models.CharField(max_length=4)

class Student(models.Model):
    roll_no = models.CharField(max_length=9)
    name = models.CharField(max_length=30)
    batch = models.CharField(max_length=4)

class Student_Courses(models.Model):
    roll_no = models.ForeignKey(Student, on_delete=models.CASCADE)
    course = models.ForeignKey(Courses , on_delete=models.CASCADE)


class Attended(models.Model):
    sid = models.ForeignKey(Sessions, on_delete=models.CASCADE)
    roll_no = models.ForeignKey(Student,on_delete=models.CASCADE)
    attended = models.BooleanField(default=False)


class Faculty(models.Model):
    faculty_id = models.CharField(max_length=10)
    name = models.CharField(max_length=30)



class Teacher_Course(models.Model):
    faculty_id = models.ForeignKey(Faculty, on_delete=models.CASCADE)
    course = models.ForeignKey(Courses, on_delete=models.CASCADE)


class Attendance(models.Model):
    course = models.ForeignKey(Courses,on_delete=models.CASCADE)
    roll_no = models.ForeignKey(Student,on_delete=models.CASCADE)

class Attendance_Details(models.Model):
    course = models.ForeignKey(Courses,on_delete=models.CASCADE)
    roll_no = models.ForeignKey(Student,on_delete=models.CASCADE)
    classes_attended = models.IntegerField(default=0)
    total_classes = models.IntegerField(default=0)

