from django.urls import path
from . import views

urlpatterns = [
    path("chat", views.chat_view, name="chat"),
    path("sim-conv/hundred", views.sim_conversations, name="hundred_sim_conversations"),
    path("sim-conv/veg", views.chat_veg_vegan, name="veg_vegan_history"),
    # path("login/", views.login_user, name="login"),
]
