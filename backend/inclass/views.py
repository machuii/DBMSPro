from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import generics, permissions
from .models import Student, Faculty, Course, Session, Classes_Attended, Total_Classes
from .serializers import StudentSerializer, FacultySerializer, SessionSerializer
from .permissions import IsFaculty
from datetime import datetime, timedelta
from .utils import classes_needed
from .utils import classes_needed
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.http import JsonResponse
from django.utils import timezone
import os


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
        batch = request.user.student.batch
        session = Session.objects.filter(
            batch=batch, end_time__gte=timezone.now()
        ).first()
        if session is not None:
            ret = {}
            ret["sid"] = session.sid
            ret["course"] = session.faculty.course_taken.course_name
            ret["end_time"] = (session.end_time + timedelta(hours=5.5)).strftime(
                "%Y-%m-%d %H:%M"
            )
            ret["faculty"] = session.faculty.name
            return Response(ret)
        # if no main course, look for elective
        student = request.user.student
        elective = student.elected_courses.first()
        session = Session.objects.filter(
            faculty__course_taken=elective, end_time__gte=timezone.now()
        ).first()
        if session is not None:
            ret = {}
            ret["sid"] = session.sid
            ret["course"] = session.faculty.course_taken.course_name
            os.environ["TZ"] = "Asia/Kolkata"
            ret["end_time"] = (session.end_time + timedelta(hours=5.5)).strftime(
                "%Y-%m-%d %H:%M"
            )
            ret["faculty"] = session.faculty.name
            return Response(ret)
        return JsonResponse({"Error details": "no sessions"}, safe=False, status=404)


@api_view(["POST"])  # attendance marking for students
def mark_attendance(request):
    if request.method == "POST":
        data = request.data
        sid = data["sid"]
        session = Session.objects.get(sid=sid)

        if session.end_time <= timezone.now():
            return Response({"error": "Session has ended"}, status=403)

        else:
            student = request.user.student
            student.attended_sessions.add(session)
            student_course = Classes_Attended.objects.get_or_create(
                course=session.faculty.course_taken, student=student
            )[0]
            student_course.classes_attended += 1
            student_course.save()
            return Response({"Attendace marked successfully"})


@api_view(["POST"])  # for faculty only
def create_session(request):
    # check if it faculty
    # permission_classes = [IsFaculty,]
    if request.method == "POST":
        data = request.data
        faculty = request.user.faculty
        duration = int(data["duration"])
        batch = data["batch"]
        # create the session
        session = Session(batch=batch, duration=duration, faculty=faculty)
        session.save()

        # increment the total number of classes of the course taken to the batch
        total_classes = Total_Classes.objects.get_or_create(
            batch=batch, course=faculty.course_taken
        )[0]
        total_classes.total_classes += 1
        total_classes.save()
        return Response({"sid": session.sid})


@api_view(
    ["GET"]
)  # for aculty to see the total number of classes of his course to each batch
def total_course_sessions(request):
    if request.method == "GET":
        course_sessions = Total_Classes.objects.all().filter(
            course=request.user.faculty.course_taken
        )
        ret = []
        for course_batch in course_sessions:
            obj = [course_batch.batch, course_batch.total_classes]
            ret.append(obj)
        return Response(ret)


@api_view(
    ["GET"]
)  # for faculty to see the the attendance of all the students of a batches
def batch_students_attendance(request):
    if request.method == "GET":
        batch = request.GET.get("batch")
        students = Student.objects.all().filter(batch=batch)
        faculty = request.user.faculty
        if faculty.course_taken.elective is True:
            students = faculty.course_taken.students_elected.all()
        else:
            batch = request.GET.get("batch")
            students = Student.objects.all().filter(batch=batch)
        ret = []
        for student in students:
            obj = [
                student.roll_no,
                student.name,
                Classes_Attended.objects.get_or_create(
                    student=student, course=request.user.faculty.course_taken
                )[0].classes_attended,
            ]
            ret.append(obj)
        return Response(ret)


@api_view(["GET"])  # for individual student
def get_attendance_statistics(request):
    if request.method == "GET":
        student = request.user.student
        core_courses = Course.objects.all().filter(elective=False)
        for course in core_courses:
            temp = Classes_Attended.objects.get_or_create(student=student, course=course)
        elective_course = Classes_Attended.objects.get_or_create(student=student, course=student.elected_courses.first()) 
        courses_attended = Classes_Attended.objects.all().filter(student=student)
        ret = []
        for course_attended in courses_attended:
            obj = {}
            obj["course_id"] = course_attended.course.course_id
            obj["course_name"] = course_attended.course.course_name
            obj["attended"] = course_attended.classes_attended
            obj["total classes"] = Total_Classes.objects.get_or_create(
                course=course_attended.course, batch=student.batch
            )[0].total_classes
            ret.append(obj)
        return Response(ret)


@api_view(["GET"])  # faculty can view the most recent 3 sessions
def recent_sessions(request):
    if request.method == "GET":
        faculty = request.user.faculty
        recent_sessions = list(
            Session.objects.filter(faculty=faculty).order_by("-start_time")
        )[:3]
        ret = []
        for session in recent_sessions:
            obj = {
                "course" : session.faculty.course_taken.course_name,
                "datetime" : (session.start_time + timedelta(hours=5.5)).strftime("%Y-%m-%d %H:%M"),
                "batch" : session.batch,
                "attendance" : session.attended_students.count(),
                "sid" : session.sid
            }
            ret.append(obj)
        return Response(ret)


@api_view(["GET"])  # for student view the complete history of a course
def student_course_history(request):
    if request.method == "GET":
        student = request.user.student
        course = Course.objects.get(course_id=request.GET.get("course_id"))
        course_sessions = Session.objects.filter(faculty__course_taken=course)
        if course.elective is False:
            course_sessions = course_sessions.filter(batch=student.batch)
        ret = []
        for course_session in course_sessions:
            obj = {}
            obj["time"] = (course_session.start_time + timedelta(hours=5.5)).strftime(
                "%Y-%m-%d %H:%M"
            )
            obj["faculty"] = course_session.faculty.name
            if student.attended_sessions.all().filter(sid=course_session.sid):
                obj["attended"] = "True"
            else:
                obj["attended"] = "False"

            ret.append(obj)
        return Response(ret)


@api_view(["GET"])
def attended_students(request):
    sid = request.GET.get("sid")
    session = Session.objects.get(sid=sid)
    attended_students = session.attended_students.all()
    ret = []
    for student in attended_students:
        obj = {}
        obj["name"] = student.name
        obj["roll_no"] = student.roll_no
        ret.append(obj)
    return Response(ret)
