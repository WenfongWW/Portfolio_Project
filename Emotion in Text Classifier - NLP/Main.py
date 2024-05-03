import streamlit as st
from transformers import pipeline

model_name = "nateraw/bert-base-uncased-emotion"
emotion_classifier = pipeline('text-classification', model=model_name)

def classify_text(text):
    prediction = emotion_classifier(text)[0]
    return prediction['label'], prediction['score']

emotions_emoji_dict = {"anger":"😠", "disgust":"🤮", "fear":"😨😱", "happy":"🤗", "joy":"😂", "neutral":"😐", "sad":"😔", "sadness":"😔", "shame":"😳", "surprise":"😮"}

def main():
    st.title("Emotion Detection in Text Classifier")
    st.subheader("Home - Emotion in Text")

    raw_text = st.text_area("Enter Text Here")
    
    if st.button('Analyze'):
        prediction, score = classify_text(raw_text)
        st.success("Original Text")
        st.write(raw_text)
        st.success("Prediction")
        emoji_icon = emotions_emoji_dict.get(prediction, "")
        st.write(f"{prediction} {emoji_icon}")
        st.success("Prediction Probability")
        st.write(f"{score * 100:.2f}%")

        if 'results' not in st.session_state:
            st.session_state['results'] = []
        
        st.session_state.results.append({'text': raw_text, 'emotion': prediction, 'score': score})

if __name__ == '__main__':
    main()
