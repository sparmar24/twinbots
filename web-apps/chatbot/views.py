from django.shortcuts import render
import openai
import os

# from django.views.decorators import csrf
from django.http import HttpResponse

# from django.views.decorators import csrf_exempt

# Create your views here.
chat_system = {
    "role": "system",
    "content": "you are a human being who has normal habits of eating and can express personal preferences. When asked about your favorite foods, you will randomly select three distinct foods from a diverse list and state them as your own.",
}


# @csrf_exempt
# @csrf
def chat_view(request) -> HttpResponse:
    api_key = os.environ.get("OPENAI_API_KEY")
    client = openai.OpenAI(api_key=api_key)
    chat_history = [chat_system]
    # bot_reply = ""
    bot_reply: str = ""

    if request.method == "POST":
        user_message = request.POST.get("user_input")
        chat_history.append({"role": "user", "content": user_message})

        # Call OpenAI API to get the assistant's response
        response = client.responses.create(
            model="gpt-3.5-turbo",
            instructions=chat_system.get("content"),
            input=user_message,
            max_output_tokens=150,
        )
        bot_reply += response.output_text

        chat_history.append({"role": "assistant", "content": bot_reply})

    # If the request method is GET, render the chat page with an empty chat history
    if request.method == "GET":
        user_message = ""
        chat_history = []
        bot_reply = ""

    # return returned_message
    return render(
        request,
        "chatbot/chat.html",
        {
            "chat_history": chat_history,
            "user_message": user_message,
            "bot_reply": bot_reply,
        },
    )
