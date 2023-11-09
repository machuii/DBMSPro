from django.urls import path
from . import views
from .views import UserProfile

urlpatterns = [
    path("profile/", UserProfile.as_view(), name="profile"),
    path("create_session/", views.create_session, name="create_session"),
    path("mark_attendance/", views.mark_attendance, name="mark_attendance"),
    path(
        "get_attendance_statistics/",
        views.get_attendance_statistics,
        name="get_attendance_statistics",
    ),
    path("fetch_sessions/", views.fetch_sessions, name="fetch_sessions"),
]
