# Vehicle Speed Estimation System

## Project Overview 
This project implements a vehicle speed estimation system using computer vision techniques. It leverages a pre-trained YOLOv8 model from Roboflow for vehicle detection and utilizes advanced tracking algorithms to estimate vehicle speeds in real-time. The system is designed to handle different traffic conditions and varying vehicle distances effectively.

![Alt text](https://github.com/WenfongWW/Portfolio_Project/blob/75afb95bd0170d554f673d09d5100e5800654060/Deep%20Learning/Vehicle%20Speed%20Estimation%20-%20Computer%20Vision/images/tracking_vehicle.png)

## Features
- **Real-time Vehicle Detection**: Utilizes YOLOv8 from Roboflow for robust vehicle detection.
- **Speed Estimation**: Calculates the speed of each vehicle based on tracking data over time.
- **Occlusion Handling**: Maintains vehicle identity even in cases of partial occlusion.
- **Enhanced Tracking**: Implements ByteTrack for improved multi-object tracking performance.

## Installation
- Python 3.8 or later
- OpenCV
- NumPy
- Supervision
- PyTorch (ensure you have the appropriate version installed for either CPU or GPU support)

## Usage
**Running the system**

```python main.py --source_video_path "path_to_your_video.mp4"```
