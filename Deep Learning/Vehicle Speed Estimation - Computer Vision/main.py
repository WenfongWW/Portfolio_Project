import argparse
import cv2
import numpy as np
from collections import defaultdict, deque
from inference.models.utils import get_roboflow_model
import supervision as sv

polygons = np.array([[1252, 787], [2298, 803], [5039, 2159], [-550, 2159]])

width = 25
height = 250

target_1 = np.array([[0,0], [width -1, 0], [width - 1, height - 1], [0, height - 1]])


def parse_arguments():
    parser = argparse.ArgumentParser(description="Vehicle Speed Estimation using Inference and Supervision")
    parser.add_argument("--source_video_path", 
                        required=False, 
                        help="Path to the source video file", 
                        type=str,
                        default="C:\\Users\\Wen\\OneDrive\\Documents\\GitHub\\Portfolio_Project\\Deep Learning\\Vehicle Speed Estimation - Computer Vision\\vehicles.mp4")
    return parser.parse_args()

class ViewTransformer:
    def __init__(self, source: np.ndarray, target: np.ndarray):
        self.m = cv2.getPerspectiveTransform(source.astype(np.float32), target.astype(np.float32))
        
    def transform_points(self, points: np.ndarray):
        reshaped_points = points.reshape(-1, 1, 2).astype(np.float32)
        transformed_points = cv2.perspectiveTransform(reshaped_points, self.m)
        return transformed_points.reshape(-1, 2)

def initialize_system(video_path):
    video_info = sv.VideoInfo.from_video_path(video_path)
    model = get_roboflow_model("yolov8x-640")
    byte_track = sv.ByteTrack(frame_rate=video_info.fps)
    thickness = sv.calculate_optimal_line_thickness(resolution_wh=video_info.resolution_wh)
    text_scale = sv.calculate_optimal_text_scale(resolution_wh=video_info.resolution_wh)
    bounding_box_annotator = sv.BoundingBoxAnnotator(thickness=thickness, color_lookup=sv.ColorLookup.TRACK)
    label_annotator = sv.LabelAnnotator(text_scale=text_scale, text_thickness=thickness, text_position=sv.Position.BOTTOM_CENTER, color_lookup=sv.ColorLookup.TRACK)
    trace_annotator = sv.TraceAnnotator(thickness=thickness, trace_length=video_info.fps * 2, position=sv.Position.BOTTOM_CENTER, color_lookup=sv.ColorLookup.TRACK)
    return model, byte_track, bounding_box_annotator, label_annotator, trace_annotator, video_info

def process_frame(frame, model, byte_track, bounding_box_annotator, label_annotator, trace_annotator, view_transformer, coordinates, polygon_zone, video_info):
    result = model.infer(frame)[0]
    detections = sv.Detections.from_inference(result)
    detections = detections[polygon_zone.trigger(detections)]
    detections = byte_track.update_with_detections(detections=detections)
    
    points = detections.get_anchors_coordinates(anchor=sv.Position.BOTTOM_CENTER)
    points = view_transformer.transform_points(points=points).astype(int)
    
    update_coordinates(coordinates, points, detections.tracker_id, video_info)
    labels = generate_labels(coordinates, detections.tracker_id, video_info)
    
    annotated_frame = frame.copy()
    annotated_frame = trace_annotator.annotate(scene=annotated_frame, detections=detections)
    annotated_frame = bounding_box_annotator.annotate(scene=annotated_frame, detections=detections)
    annotated_frame = label_annotator.annotate(scene=annotated_frame, detections=detections, labels=labels)
    return annotated_frame

def update_coordinates(coordinates, points, tracker_ids, video_info):
    for tracker_id, [_, y] in zip(tracker_ids, points):
        coordinates[tracker_id].append(y)

def generate_labels(coordinates, tracker_ids, video_info):
    labels = []
    for tracker_id in tracker_ids:
        if len(coordinates[tracker_id]) < video_info.fps / 2:
            labels.append(f"#{tracker_id} Insufficient data")
        else:
            coordinate_start = coordinates[tracker_id][-1]
            coordinate_end = coordinates[tracker_id][0]
            distance = abs(coordinate_start - coordinate_end)
            time = len(coordinates[tracker_id]) / video_info.fps
            speed = distance / time * 3.6
            labels.append(f"#{tracker_id} {int(speed)} km/h")
    return labels

if __name__ == "__main__":
    args = parse_arguments()
    model, byte_track, bounding_box_annotator, label_annotator, trace_annotator, video_info = initialize_system(args.source_video_path)
    frame_generator = sv.get_video_frames_generator(args.source_video_path)
    polygon_zone = sv.PolygonZone(polygons, frame_resolution_wh=video_info.resolution_wh)
    view_transformer = ViewTransformer(source=polygons, target=target_1)
    coordinates = defaultdict(lambda: deque(maxlen=video_info.fps))

    cv2.namedWindow("Annotated Frame", cv2.WINDOW_NORMAL)
    cv2.resizeWindow("Annotated Frame", 800, 600)

    try:
        for frame in frame_generator:
            annotated_frame = process_frame(frame, model, byte_track, bounding_box_annotator, label_annotator, trace_annotator, view_transformer, coordinates, polygon_zone, video_info)
            resized_frame = cv2.resize(annotated_frame, (800, 600))
            cv2.imshow("Annotated Frame", resized_frame)
            if cv2.waitKey(1) == ord("q"):
                break
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        cv2.destroyAllWindows()
