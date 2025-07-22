from django.shortcuts import render
from openai import OpenAI
import os
import psycopg
from django.http import HttpResponse
from simulated_conversations import chatbotA


def chat_view(request) -> HttpResponse:
    chat_system = {
        "role": "system",
        "content": "you are a human being who has normal habits of eating and can express personal preferences. When asked about your favorite foods, you will randomly select three distinct foods from a diverse list and state them as your own.",
    }
    api_key = os.environ.get("OPENAI_API_KEY")
    client = OpenAI(api_key=api_key)
    bot_reply: str = ""
    response_a = chatbotA()

    if request.method == "POST":
        user_message = request.POST.get("user_input")

        response = client.responses.create(
            model="gpt-3.5-turbo",
            instructions=chat_system.get("content"),
            input=user_message,
            max_output_tokens=150,
        )
        bot_reply += response.output_text
        bot_response = {"role": "assistant", "content": bot_reply}

    if request.method == "GET":
        user_message = ""
        bot_response = {"role": "ChatBot-A", "content": response_a}
        bot_reply = ""

    return render(
        request,
        "chatbot/chat.html",
        {
            "bot_responses": [bot_response],
            "user_message": user_message,
            "bot_reply": bot_reply,
        },
    )


def chat_veg_vegan(request):
    # Connect to the PostgreSQL database
    conn = psycopg.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
    )
    cursor = conn.cursor()
    # Fetch chat history from the database
    cursor.execute("""
            SELECT dietary_habit, top_three_foods 
            FROM final_sim_conversations 
            LIMIT 100
    """)
    rows = cursor.fetchall()
    chat_history = [
        {"role": row[0], "content": row[1]}
        for row in rows
        # {"dietary_habbit": row[0], "three_favourite_foods": row[1]} for row in rows
    ]
    cursor.close()
    conn.close()

    return render(
        request,
        "chatbot/veg_vegan_history.html",
        {
            "chat_history": chat_history,
        },
    )
