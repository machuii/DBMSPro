from rest_framework import permissions


class IsFaculty(permissions.BasePermission):
    def has_permission(self, request, view):

        if request.user.faculty is None:
            return False
        return True

    
    def has_object_permission(self, request, view, obj):
        return True

