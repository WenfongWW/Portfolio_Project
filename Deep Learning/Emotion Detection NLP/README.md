# Emotion in Text Classifier

## Overview

This Streamlit web application classifies emotions in text snippets using a pre-trained model from Hugging Face's transformers library. It's designed to demonstrate how natural language processing can be utilized to detect emotions in written content, enhancing understanding in user interactions, feedback analysis, and social media monitoring.

## Key Features

- **Interactive Text Input**: Users can type or paste text into the app and receive an instant classification of the underlying emotion.
- **Emotion Prediction with Emoji**: The app predicts the emotion of the input text and enhances the display with an intuitive emoji representation.
- **Confidence Score**: Alongside each prediction, the app provides a probability score, indicating the model's confidence in its prediction.

## How It Works

The app uses the `bert-base-uncased-emotion` model from Hugging Face, which has been fine-tuned for emotion recognition tasks. When text is entered, the model processes and classifies it into categories such as joy, sadness, anger, etc., displaying the most likely emotion along with its confidence score.

## Use Cases

- **Customer Feedback Analysis**: Automatically analyze and categorize customer sentiments in feedback and reviews.
- **Social Media Monitoring**: Monitor social media posts for emotional content to gauge public sentiment or detect urgent issues.
- **Mental Health Monitoring**: Help in mental health platforms to detect emotions and provide insights or alerts.


![Alt text](https://github.com/WenfongWW/Portfolio-Project/blob/28f251d20f1ec8a7255096f54d0c91f34f4cebb5/Deep%20Learning/NLP/Emotion%20in%20Text%20Classifier%20-%20NLP/images/emotion_streamlit.png)


