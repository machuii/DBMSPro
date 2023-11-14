import math


def find_classes_needed(attended, total_classes, needed_percentage):
    num = attended - (needed_percentage * total_classes)
    denom = needed_percentage - 1

    if denom == 0:
        return "Not Possible"
    return math.ceil(num / denom)
