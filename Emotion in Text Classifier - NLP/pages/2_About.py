import streamlit as st
from transformers import pipeline


def main():
    st.title("About")
    st.write("This is an app for classifying emotions in text using a machine learning model built with the Transformers library.")

if __name__ == '__main__':
    main()
