from django.shortcuts import render
from rest_framework import generics, permissions
from .models import Student, Faculty
from .serializers import StudentSerializer, FacultySerializer



class UserProfile(generics.RetrieveAPIView):
    permission_classes = [permissions.IsAuthenticated]
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    
    def get_serializer_class(self):
            try:
                student = self.request.user.student
                if student:
                    return StudentSerializer
            except Student.DoesNotExist:
                pass

            # Attempt to retrieve the associated Faculty instance for the logged-in user
            try:
                faculty = self.request.user.faculty
                if faculty:
                    return FacultySerializer
            except Faculty.DoesNotExist:
                pass


    def get_object(self):
            try:
                student = self.request.user.student
                if student:
                    return student
            except Student.DoesNotExist:
                pass

            try:
                faculty = self.request.user.faculty
                if faculty:
                    return faculty
            except Faculty.DoesNotExist:
                pass


