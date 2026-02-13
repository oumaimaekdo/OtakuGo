import json
import os

file_path = '/home/zidee/StudioProjects/otakugo/assets/anime_1000.json'

try:
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    if isinstance(data, list):
        count = 0
        for item in data:
            if 'local_image_raw' in item:
                del item['local_image_raw']
                count += 1
        print(f"Removed local_image_raw from {count} items.")
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)
    
    print("Successfully updated file.")
except Exception as e:
    print(f"Error: {e}")
