from django.urls import path
from . import views
from .views import UserProfile, SessionList, total_course_sessions, batch_students_attendance, student_course_history, attended_students

urlpatterns = [
    path("profile/", UserProfile.as_view(), name="profile"),
    path("create_session/", views.create_session, name="create_session"),
    path("course_sessions/", total_course_sessions, name="total_course_sessions"),
    path("mark_attendance/", views.mark_attendance, name="mark_attendance"),
    path("course_attendance/", views.get_attendance_statistics, name="get_attendance_statistics",),
    path("fetch_sessions/", views.fetch_sessions, name="fetch_sessions"),
    path("batch_attendance/", batch_students_attendance, name="batch_attendance"),
    path("recent_sessions/", views.recent_sessions, name="recent_sessions"),
    path("course_history/", student_course_history, name="course_history"),
    path("attended_students", attended_students, name="attended_students"),
    # for testing
    path("sessions/", SessionList.as_view(), name="sessions_list"),
]
