from openai import OpenAI

client = OpenAI(
    api_key="ollama",
    base_url="http://localhost:12000/v1"
)

response = client.chat.completions.create(
    model="llama3.1:8b",
    messages=[{"role": "user", "content": "現在の最新の西暦について教えて"}],
    temperature=0 # 質問に対しての揺らぎ , 0 => なし , 値が大きいと揺らぐ（確定的ではない）　デフォルト 0.3
)

### 結果出力 ###
print("response全体：", response)
print("テキスト抽出：", response.choices[0].message.content)