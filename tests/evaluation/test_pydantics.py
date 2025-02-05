from pydantic import BaseModel, Field
import os
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()


class BookInfo(BaseModel):
    title: str = Field(..., description="The title of the book")
    author: str = Field(..., description="The author of the book")
    publication_year: int = Field(..., description="The year the book was published")
    genre: str = Field(..., description="The genre of the book")


# Load environment variables from a .env file

# Initialize the OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def extract_book_info(text):
    response = client.beta.chat.completions.parse(
        model="gpt-4o-mini",
        messages=[
            {
                "role": "system",
                "content": "You are a literary expert. Extract detailed information about the book mentioned.",
            },
            {"role": "user", "content": text},
        ],
        response_format=BookInfo,
    )
    return response.choices[0].message.parsed


if __name__ == "__main__":
    text = "The book 'To Kill a Mockingbird' was written by Harper Lee and published in 1960. It is a classic of modern American literature."
    book_info = extract_book_info(text)
    print(book_info)
    # Output: title='To Kill a Mockingbird' author='Harper Lee' publication_year=1960 genre='Fiction'
