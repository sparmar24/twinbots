from django.urls import path
from . import views

urlpatterns = [
    path("user", views.chat_view, name="chat"),
    path("user/veg", views.chat_veg_vegan, name="veg_vegan_history"),
]
