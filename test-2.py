import streamlit as st 
from openai import OpenAI

# ページタイトル
st.set_page_config(page_title="ローカル LLM Chat")

st.sidebar.title("設定")
model = st.sidebar.text_input("モデル名", value="llama3.1:8b")
temperature = st.sidebar.slider("temperature", 0.0, 2.0, 0.3, 0.1)
system_prompt = st.sidebar.text_area(
    "System Prompt",
    "あなたの有能なアシスタントです。日本語で回答してください。"
)

prompt = st.chat_input("メッセージを入力")

client = OpenAI(
    api_key="ollama",
    base_url="http://localhost:12000/v1"
)


### 結果出力 ###
# print("response全体：", response)
# print("テキスト抽出：", response.choices[0].message.content)

if prompt:
    response = client.chat.completions.create(
        model=model,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt},
        ],
        temperature=temperature,
    )

    st.write(response.choices[0].message.content)
else:
    st.info("メッセージを入力して送信してください。")