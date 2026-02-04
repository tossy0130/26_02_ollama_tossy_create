from openai import OpenAI

client = OpenAI(
    api_key="ollama",
    base_url="http://localhost:12000/v1"
)

stream_response = client.chat.completions.create(
    model="llama3.1:8b",
    messages=[{"role": "user", "content": "こんにちは"}],
    temperature=0.3, # 質問に対しての揺らぎ , 0 => なし , 値が大きいと揺らぐ（確定的ではない）　デフォルト 1
    stream=True
)

for chunk in stream_response:
    print(chunk.choices[0].delta.content)