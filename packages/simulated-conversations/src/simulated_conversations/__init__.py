import os
from openai import OpenAI
import psycopg


def bot_response(instructions, user_message) -> str:
    api_key = os.environ.get("OPENAI_API_KEY")
    client = OpenAI(api_key=api_key)

    response = client.responses.create(
        model="gpt-3.5-turbo",
        instructions=instructions,
        input=user_message,
        max_output_tokens=50,
    )
    return response.output_text


def chatbotA() -> str:
    instructions = (
        "You are a chatbot conducting a survey."
        "You are going door to door and asking persons about there favourite foods."
    )
    user_message = "Please ask me what my three favourite foods are."
    return bot_response(instructions, user_message)


def chatbotB(user_message) -> str:
    instructions = (
        "You are a person living in a diverse neighbourhood where people from all over the world are staying."
        "You could be a vegetarian or a non-vegetarian or a vegan or just anyone."
        "Be concise in your answer."
        "Also specify if you are a vegetarian or a non-vegetarian or a vegan."
    )
    # user_message = "What are your three favourite foods?"
    return bot_response(instructions, user_message)


def conversation():
    # print("Chatbot A:")
    response_a = chatbotA()
    # print(response_a)

    # print("\nChatbot B:")
    response_b = chatbotB(response_a)
    # print(response_b)
    return response_b


def main():
    for i in range(10):
        print(f"\nConversation {i + 1}:")
        answer = conversation()

        conn = psycopg.connect(
            dbname=os.environ.get("DB_NAME"),
            user=os.environ.get("DB_USER"),
            password=os.environ.get("DB_PASSWORD"),
            host=os.environ.get("DB_HOST"),
            port=os.environ.get("DB_PORT"),
        )
        # create table if not exis
        cursor = conn.cursor()
        # create table
        cursor.execute(
            """CREATE TABLE IF NOT EXISTS simulated_conversations (
                id SERIAL PRIMARY KEY,
                answer TEXT NOT NULL
            )"""
        )
        # insert data
        cursor.execute(
            "INSERT INTO simulated_conversations (answer) VALUES (%s)", (answer,)
        )
        cursor.close()
        conn.commit()
        conn.close()
