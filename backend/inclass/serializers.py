from rest_framework import serializers
from .models import Student, Faculty



class StudentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Student
        fields = ("roll_no", "name", "batch")



class FacultySerializer(serializers.ModelSerializer):

    course_taken = serializers.CharField(source='course_taken.course_name')
    class Meta:
        model = Faculty
        fields = ("faculty_id", "name", "course_taken")