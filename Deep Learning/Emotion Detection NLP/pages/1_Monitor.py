import streamlit as st
from transformers import pipeline
import plotly.express as px


model_name = "nateraw/bert-base-uncased-emotion"
emotion_classifier = pipeline('text-classification', model=model_name)

def classify_text(text):
    prediction = emotion_classifier(text)[0]
    return prediction['label'], prediction['score']


def main():
    st.title("Monitor App")
    st.write("This page could display data analytics, visualizations, logs, etc.")

if __name__ == '__main__':
    main()
