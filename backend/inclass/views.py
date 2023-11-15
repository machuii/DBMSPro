from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import generics, permissions
from .models import Student, Faculty, Course, Session, Classes_Attended, Total_Classes
from .serializers import StudentSerializer, FacultySerializer, SessionSerializer
from .permissions import IsFaculty
from datetime import datetime
from .utils import find_classes_needed


class SessionList(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    queryset = Session.objects.all()
    serializer_class = SessionSerializer

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


@api_view(["GET"])  # to get sessions when they refresh
def fetch_sessions(request):
    if request.method == "GET":
        data = request.data
        batch = data["batch"]
        sessions = Session.objects.filter(
             batch=batch, end_time__lte=datetime.now()
        )
        return Response({"sessions": sessions})


@api_view(["PUT"])  # attendance marking for students
def mark_attendance(request):
    if request.method == "PUT":
        data = request.data
        roll_no = data["roll_no"]
        course_id = data["course_id"]
        received_sid = data["sid"]
        student = Student.objects.get(roll_no=roll_no)
        course = Course.objects.get(course_id=course_id)
        session_id = Session.objects.get(sid=received_sid)

        if session_id.end_time <= datetime.now():
            return Response({"error": "Session has ended"})

        else:
            Class_attended = Classes_Attended.objects.get(
                roll_no=roll_no, course_id=course_id
            )
            if Classes_attended is None:
                Classes_attended = Classes_Attended(
                    roll_no=roll_no, course_id=course_id, classes_attended=1
                )
                Classes_attended.save()
            else:
                Classes_attended.classes_attended += 1
                Classes_attended.save()


@api_view(["POST"])  # for faculty only
def create_session(request):
    # check if it faculty
    # permission_classes = [IsFaculty,]
    if request.method == "POST":
        data = request.data
        faculty = request.user.faculty
        duration = int(data["duration"])
        batch = data["batch"]
        #create the session
        session = Session(batch=batch, duration=duration, faculty=faculty)
        session.save()
        
        #increment the total number of classes of the course taken to the batch
        total_classes = Total_Classes.objects.get_or_create(batch=batch, course=faculty.course_taken)[0]
        total_classes.total_classes += 1
        total_classes.save()
        return Response({"sid": session.sid})


@api_view(["GET"])  # for individual student
def get_attendance_statistics(request):
    if request.method == "GET":
        data = request.data
        course_id = data["course_id"]
        batch = data["batch"]
        roll_no = data["roll_no"]
        course = Course.objects.get(course_id=course_id)
        total_classes = Total_Classes.objects.get(
            course=course, batch=batch
        ).total_classes
        classes_attended = Classes_Attended.objects.get(
            roll_no=roll_no, course=course
        ).classes_attended
        attendance_statistics = {}
        attendance_statistics["total_classes"] = total_classes
        attendance_statistics["classes_attended"] = classes_attended
        attendance_statistics["attendance_percentage"] = (
            classes_attended / total_classes
        ) * 100
        attendance_statistics["classes_needed"] = find_classes_needed(
            classes_attended, total_classes, 70
        )
        return Response({"attendance_statistics": attendance_statistics})

