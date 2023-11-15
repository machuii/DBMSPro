from django.shortcuts import render
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import generics, permissions
from .models import Student, Faculty, Course, Session, Classes_Attended, Total_Classes
from .serializers import StudentSerializer, FacultySerializer, SessionSerializer
from .permissions import IsFaculty
from datetime import datetime
from .utils import find_classes_needed
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.http import JsonResponse
from django.utils import timezone


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
        session = Session.objects.filter(batch=batch, end_time__gte=timezone.now()).first()
        if session is not None:
            ret = {}
            ret["sid"] = session.sid
            ret["course"] = session.faculty.course_taken.course_name
            ret["end_time"] = session.end_time.strftime("%Y-%m-%d %H:%M")
            ret["faculty"] = session.faculty.name
            return Response(ret)
        return JsonResponse({"Error details" : "no sessions"}, safe=False, status=404)


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



@api_view(["GET"]) # for aculty to see the total number of classes of his course to each batch
def total_course_sessions(request):
    if request.method == "GET":
        course_sessions = Total_Classes.objects.all().filter(
            course=request.user.faculty.course_taken
        )
        ret = {}
        for course_batch in course_sessions:
            ret[course_batch.batch] = course_batch.total_classes
        return Response(ret)



@api_view(["GET"]) # for faculty to see the the attendance of all the students of a batches
def batch_students_attendance(request):
    if request.method == "GET":
        batch = request.GET.get('batch')
        students = Student.objects.all().filter(batch=batch)
        ret = []
        for student in students:
            obj = [student.roll_no, student.name, Classes_Attended.objects.get_or_create(roll_no=student, course=request.user.faculty.course_taken)[0].classes_attended]
            ret.append(obj)
        return Response(ret)



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
                "datetime" : session.start_time.strftime("%Y-%m-%d %H:%M"),
                "batch" : session.batch,
                "attendance" : session.attended_students.count()
            }
            ret.append(obj)
        return Response(ret)
        return Response(recent_sessions)
